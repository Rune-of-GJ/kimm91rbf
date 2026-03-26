class PagesController < ApplicationController
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
  end

  def my_courses
    @active_page = :my_courses
  end

  def lecture_player
    @active_page = :lecture_player
  end

  def progress
    @active_page = :progress
  end
end
