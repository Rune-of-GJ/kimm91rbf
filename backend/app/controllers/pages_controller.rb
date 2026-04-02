class PagesController < ApplicationController
  before_action :set_current_user
  before_action :set_categories, only: [:dashboard, :categories, :api_lab]
  before_action :set_courses, only: [:dashboard, :courses, :api_lab]

  def dashboard
    @selected_category = Category.find_by(id: params[:category]) if params[:category].present?
  end

  def categories; end
  def courses; end
  def my_courses; end
  def progress; end
  def lecture_player; end

  private

  def set_current_user
    @current_user = User.find_by(id: session[:user_id]) if session[:user_id]
  end

  def set_categories
    @categories = Category.includes(:courses).order(:name)
  end

  def set_courses
    scope = Course.includes(:category, :lectures).order(created_at: :desc)
    @courses = @selected_category ? scope.where(category_id: @selected_category.id) : scope
  end
end
