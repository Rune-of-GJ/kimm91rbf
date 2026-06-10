class PagesController < ApplicationController
  before_action :require_login_for_html!, only: [:my_courses, :progress]
  before_action :set_categories, only: [:dashboard, :categories, :courses, :api_lab]
  before_action :set_selected_category, only: [:dashboard, :courses]
  before_action :set_courses, only: [:dashboard, :courses, :api_lab]
  before_action :set_lab_samples, only: [:api_lab]
  before_action :ensure_lecture_access!, only: [:lecture_player]

  def dashboard; end

  def categories; end

  def courses; end

  def course_detail
    @course = Course.includes(:lectures).find(params[:id])
    @lectures = @course.lectures.order(:order_no)
  end

  def my_courses; end

  def lecture_player
    @lecture = Lecture.includes(:course).find(params[:id])
    @course = @lecture.course
  end

  def progress; end

  def login; end

  def api_lab; end

  private

  def set_categories
    @categories = Category.includes(:courses).order(:name)
  end

  def set_selected_category
    @selected_category = Category.find_by(id: params[:category]) if params[:category].present?
  end

  def set_courses
    scope = Course.includes(:category, :lectures).order(created_at: :desc)
    @courses = @selected_category ? scope.where(category_id: @selected_category.id) : scope
  end

  def set_lab_samples
    @lab_category = @categories.first
    @lab_course = @courses.first || Course.includes(:lectures).first
    @lab_lecture = @lab_course&.lectures&.first || Lecture.includes(:course).order(:order_no).first
  end

  def ensure_lecture_access!
    lecture = Lecture.includes(:course).find(params[:id])

    unless current_user
      redirect_to login_path, alert: "로그인이 필요합니다."
      return
    end

    unless current_user.can_access_course?(lecture.course)
      redirect_to course_detail_path(lecture.course), alert: "멤버십 가입 후에 강의를 시청할 수 있습니다."
    end
  end
end
