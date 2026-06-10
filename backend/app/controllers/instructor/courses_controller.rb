module Instructor
  class CoursesController < BaseController
    before_action :set_categories, only: [:new, :create, :edit, :update]
    before_action :set_instructor_course, only: [:edit, :update, :destroy]
    skip_before_action :require_instructor_access!, only: [:access_denied]

    def index
      @instructor_courses = current_user.instructed_courses.includes(:category, :lectures, :enrollments).order(created_at: :desc)
      @instructor_counts = build_counts(@instructor_courses)
    end

    def new
      @course = current_user.instructed_courses.new(default_course_attributes)
      @lecture_rows = [default_lecture_row]
      @instructor_counts = build_counts(current_user.instructed_courses)
    end

    def edit
      @instructor_counts = build_counts(current_user.instructed_courses)
      @new_lecture = @course.lectures.new(order_no: next_lecture_order_no)
    end

    def create
      @course = current_user.instructed_courses.new(default_course_attributes.merge(course_params.to_h.symbolize_keys))
      @course.instructor_name = current_user.name
      @lecture_rows = normalized_lecture_rows
      @instructor_counts = build_counts(current_user.instructed_courses)

      validate_course_submission(@course)
      validate_lecture_rows(@course, @lecture_rows)

      if @course.errors.any?
        flash.now[:alert] = @course.errors.full_messages.join(", ")
        render :new, status: :unprocessable_entity
        return
      end

      Course.transaction do
        @course.save!
        attach_thumbnail_upload(@course, params.dig(:course, :thumbnail_file))
        create_lectures!(@course, @lecture_rows)
      end

      redirect_to instructor_courses_path, notice: "강의를 등록했습니다."
    rescue ActiveRecord::RecordInvalid => error
      flash.now[:alert] = error.record.errors.full_messages.join(", ")
      render :new, status: :unprocessable_entity
    end

    def update
      @course.assign_attributes(course_params)
      @course.instructor_name = current_user.name
      @instructor_counts = build_counts(current_user.instructed_courses)
      validate_course_submission(@course)

      if @course.save
        attach_thumbnail_upload(@course, params.dig(:course, :thumbnail_file))
        redirect_to instructor_courses_path, notice: "강의 정보를 수정했습니다."
      else
        flash.now[:alert] = @course.errors.full_messages.join(", ")
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @course.destroy!
      redirect_to instructor_courses_path, notice: "강의를 삭제했습니다."
    end

    def access_denied; end

    private

    def course_params
      params.require(:course).permit(
        :title,
        :description,
        :category_id,
        :start_date,
        :end_date,
        :enrollment_deadline
      )
    end

    def set_categories
      @categories = Category.order(:name)
    end

    def set_instructor_course
      @course = current_user.instructed_courses.find(params[:id])
    end

    def default_course_attributes
      distant_future = 10.years.from_now.to_date

      {
        enrollment_deadline: distant_future,
        start_date: Date.current,
        end_date: distant_future
      }
    end

    def default_lecture_row
      {
        "title" => "",
        "video_url" => ""
      }
    end

    def normalized_lecture_rows
      raw_rows = params.dig(:course, :lecture_rows_attributes)
      rows =
        case raw_rows
        when ActionController::Parameters
          raw_rows.to_unsafe_h.values
        when Hash
          raw_rows.values
        when Array
          raw_rows
        else
          []
        end

      normalized = rows.filter_map do |row|
        next if row.blank?

        source = row.respond_to?(:to_unsafe_h) ? row.to_unsafe_h : row
        source = source.stringify_keys

        {
          "title" => source["title"].to_s.strip,
          "video_url" => source["video_url"].to_s.strip
        }
      end.reject { |row| row.values.all?(&:blank?) }

      normalized.presence || [default_lecture_row]
    end

    def attach_thumbnail_upload(course, upload)
      return if upload.blank?

      uploads_dir = Rails.root.join("public", "uploads", "course_thumbnails")
      FileUtils.mkdir_p(uploads_dir)

      extension = File.extname(upload.original_filename.to_s).presence || ".bin"
      filename = "course-#{course.id}-#{SecureRandom.hex(8)}#{extension}"
      absolute_path = uploads_dir.join(filename)

      File.binwrite(absolute_path, upload.read)
      course.update_column(:thumbnail_url, "/uploads/course_thumbnails/#{filename}")
    end

    def validate_course_submission(course)
      if course.description.to_s.strip.length < 10
        course.errors.add(:description, "강의 소개는 10자 이상 입력해 주세요.")
      end

      if course.category_id.blank?
        course.errors.add(:category, "카테고리를 선택해 주세요.")
      end
    end

    def validate_lecture_rows(course, lecture_rows)
      rows = lecture_rows.reject { |row| row.values.all?(&:blank?) }

      if rows.empty?
        course.errors.add(:base, "강의편을 1개 이상 추가해 주세요.")
        return
      end

      rows.each_with_index do |row, index|
        if row["title"].blank?
          course.errors.add(:base, "강의편 #{index + 1}의 제목을 입력해 주세요.")
        end

        if row["video_url"].blank?
          course.errors.add(:base, "강의편 #{index + 1}의 동영상 주소를 입력해 주세요.")
        end
      end
    end

    def create_lectures!(course, lecture_rows)
      lecture_rows.each_with_index do |row, index|
        cleaned_url, derived_duration = normalize_youtube_url(row["video_url"])

        course.lectures.create!(
          title: row["title"],
          video_url: cleaned_url,
          duration: derived_duration,
          order_no: index + 1
        )
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

    def next_lecture_order_no
      (@course.lectures.maximum(:order_no) || 0) + 1
    end
  end
end
