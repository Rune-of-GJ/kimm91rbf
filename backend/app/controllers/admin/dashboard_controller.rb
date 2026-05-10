module Admin
  class DashboardController < BaseController
    skip_before_action :require_admin_access!, only: :access_denied
    skip_before_action :redirect_to_setup_if_needed, only: :access_denied

    def show
      @admin_counts = {
        users: User.count,
        instructors: User.where(role: :instructor).count,
        students: User.where(role: :student).count,
        courses: Course.count,
        categories: Category.count
      }
      @recent_users = User.order(created_at: :desc).limit(5)
      @recent_courses = Course.includes(:category).order(created_at: :desc).limit(5)
    end

    def access_denied; end
  end
end
