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
      @instructor_counts = build_counts(current_user.instructed_courses)
    end

    def edit
      @instructor_counts = build_counts(current_user.instructed_courses)
    end

    def create
      @course = current_user.instructed_courses.new(course_params)
      @course.instructor_name = current_user.name
      @instructor_counts = build_counts(current_user.instructed_courses)
      validate_course_submission(@course)

      if @course.save
        attach_thumbnail_upload(@course, params.dig(:course, :thumbnail_file))
        redirect_to instructor_courses_path, notice: "강의 등록에 성공했습니다!"
      else
        flash.now[:alert] = @course.errors.full_messages.join(", ")
        render :new, status: :unprocessable_entity
      end
    end

    def update
      @course.assign_attributes(course_params)
      @course.instructor_name = current_user.name
      @instructor_counts = build_counts(current_user.instructed_courses)
      validate_course_submission(@course)

      if @course.save
        attach_thumbnail_upload(@course, params.dig(:course, :thumbnail_file))
        redirect_to instructor_courses_path, notice: "강의 수정에 성공했습니다!"
      else
        flash.now[:alert] = @course.errors.full_messages.join(", ")
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @course.destroy!
      redirect_to instructor_courses_path, notice: "강의 삭제에 성공했습니다!"
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
        course.errors.add(:description, "must be at least 10 characters")
      end

      if course.category_id.blank?
        course.errors.add(:category, "must be selected")
      end
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
