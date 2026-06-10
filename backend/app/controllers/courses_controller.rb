class CoursesController < ApplicationController
  before_action :require_login!

  def enroll
    course = Course.find(params[:id])

    unless Enrollment.exists?(user: current_user, course: course)
      current_user.enrolled_courses << course
    end

    redirect_to root_path(tab: "my-courses"), notice: "수강신청이 완료되었습니다."
  end
end