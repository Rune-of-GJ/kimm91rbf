module Instructor
  module Courses
    class LecturesController < BaseController
      before_action :set_course
      before_action :set_lecture, only: [:edit, :update, :destroy]

      def new
        @lecture = @course.lectures.new(order_no: next_order_no)
        @instructor_counts = build_counts(current_user.instructed_courses)
      end

      def create
        cleaned_url, derived_duration = normalize_youtube_url(lecture_params[:video_url])
        @lecture = @course.lectures.new(
          title: lecture_params[:title],
          video_url: cleaned_url,
          duration: derived_duration,
          order_no: next_order_no
        )
        @instructor_counts = build_counts(current_user.instructed_courses)

        if @lecture.save
          redirect_to edit_instructor_course_path(@course), notice: "강의편을 추가했습니다."
        else
          flash.now[:alert] = @lecture.errors.full_messages.join(", ")
          render :new, status: :unprocessable_entity
        end
      end

      def edit
        @instructor_counts = build_counts(current_user.instructed_courses)
      end

      def update
        @instructor_counts = build_counts(current_user.instructed_courses)

        cleaned_url, derived_duration = normalize_youtube_url(lecture_params[:video_url])

        if @lecture.update(
          title: lecture_params[:title],
          video_url: cleaned_url,
          duration: derived_duration || @lecture.duration
        )
          redirect_to edit_instructor_course_path(@course), notice: "강의편을 수정했습니다."
        else
          flash.now[:alert] = @lecture.errors.full_messages.join(", ")
          render :edit, status: :unprocessable_entity
        end
      end

      def destroy
        @lecture.destroy!
        reorder_lectures!
        redirect_to edit_instructor_course_path(@course), notice: "섹션을 삭제했습니다."
      end

      private

      def set_course
        @course = current_user.instructed_courses.includes(:lectures).find(params[:course_id])
      end

      def set_lecture
        @lecture = @course.lectures.find(params[:id])
      end

      def lecture_params
        params.require(:lecture).permit(:title, :video_url)
      end

      def next_order_no
        (@course.lectures.maximum(:order_no) || 0) + 1
      end

      def reorder_lectures!
        @course.lectures.order(:order_no, :id).each_with_index do |lecture, index|
          lecture.update_column(:order_no, index + 1)
        end
      end

      def normalize_youtube_url(url)
        return [url, nil] if url.blank?

        uri = URI.parse(url)
        params = CGI.parse(uri.query.to_s)
        seconds = extract_seconds(params["t"].first || params["start"].first)
        params.delete("t")
        params.delete("start")

        uri.query = params.any? ? URI.encode_www_form(params.transform_values(&:first)) : nil
        cleaned_url = uri.to_s
        duration_minutes = seconds.present? ? [(seconds.to_f / 60).ceil, 1].max : nil

        [cleaned_url, duration_minutes]
      rescue URI::InvalidURIError
        [url, nil]
      end

      def extract_seconds(token)
        return if token.blank?
        return token.to_i if token.to_s.match?(/\A\d+\z/)

        hours = token.to_s[/(\d+)h/, 1].to_i
        minutes = token.to_s[/(\d+)m/, 1].to_i
        seconds = token.to_s[/(\d+)s/, 1].to_i
        total = (hours * 3600) + (minutes * 60) + seconds
        total.positive? ? total : nil
      end

      def build_counts(scope)
        {
          courses: scope.count,
          categories: Category.count,
          upcoming: scope.where("start_date >= ?", Date.current).count
        }
      end
    end
  end
end
