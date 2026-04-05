class PagesController < ApplicationController
  before_action :set_current_user
  before_action :set_categories, only: [:dashboard, :categories, :courses, :api_lab]
  before_action :set_selected_category, only: [:dashboard, :courses]
  before_action :set_courses, only: [:dashboard, :courses, :api_lab]

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

  private

  def set_current_user
    @current_user = User.find_by(id: session[:user_id]) if session[:user_id]
  end

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
end
