class PagesController < ApplicationController
  before_action :set_demo_user
  before_action :set_categories, only: [:dashboard, :categories, :api_lab]
  before_action :set_courses, only: [:dashboard, :courses, :api_lab]
  before_action :set_featured_course, only: [:dashboard, :course_detail, :lecture_player, :api_lab]
  before_action :set_my_courses, only: [:my_courses, :progress, :api_lab]

  def dashboard
    @active_page = :dashboard
  end

  def signup
    @active_page = :signup
  end

  def login
    @active_page = :login
  end

  def categories
    @active_page = :categories
  end

  def courses
    @active_page = :courses
  end

  def course_detail
    @active_page = :course_detail
    @curriculum = @featured_course&.lectures&.order(:order_no) || []
  end

  def my_courses
    @active_page = :my_courses
  end

  def lecture_player
    @active_page = :lecture_player
    @curriculum = @featured_course&.lectures&.order(:order_no) || []
    @current_lecture = if params[:lecture_id].present?
      @curriculum.find { |lecture| lecture.id == params[:lecture_id].to_i }
    else
      @curriculum.first
    end
    @current_progress = @demo_user&.progresses&.find_by(lecture: @current_lecture)
  end

  def progress
    @active_page = :progress
  end

  def api_lab
    @active_page = :api_lab
    @lab_course = @featured_course
    @lab_lecture = @lab_course&.lectures&.order(:order_no)&.first
    @lab_category = @categories.first
  end

  private

  def set_demo_user
    @demo_user = User.find_by(email: "student@speakflow.kr")
  end

  def set_categories
    @categories = Category.includes(:courses).order(:name)
  end

  def set_courses
    scope = Course.includes(:category, :lectures).order(created_at: :desc)
    @selected_category = Category.find_by(id: params[:category_id]) if params[:category_id].present?
    @courses = @selected_category ? scope.where(category_id: @selected_category.id) : scope
  end

  def set_featured_course
    scope = Course.includes(:category, :lectures).order(created_at: :desc)
    @featured_course = if params[:course_id].present?
      scope.find_by(id: params[:course_id])
    elsif params[:category_id].present?
      scope.find_by(category_id: params[:category_id]) || scope.first
    else
      scope.first
    end
  end

  def set_my_courses
    @my_courses = @demo_user&.enrolled_courses&.includes(:category, :lectures)&.order(created_at: :desc) || []
  end
end
