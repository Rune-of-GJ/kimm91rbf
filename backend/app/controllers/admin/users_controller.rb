module Admin
  class UsersController < BaseController
    before_action :set_user, only: [:update, :destroy]

    def index
      role_counts = User.group(:role).count
      @admin_counts = {
        users: role_counts.values.sum,
        admins: role_counts["admin"].to_i,
        instructors: role_counts["instructor"].to_i,
        students: role_counts["student"].to_i
      }

      @role_filter = params[:role].presence_in(%w[all admin instructor student]) || "all"
      @query = params[:q].to_s.strip

      scope = User.includes(:enrollments, :instructed_courses).order(created_at: :desc)
      scope = scope.where(role: @role_filter) unless @role_filter == "all"

      if @query.present?
        pattern = "%#{ActiveRecord::Base.sanitize_sql_like(@query)}%"
        scope = scope.where("name LIKE :pattern OR email LIKE :pattern", pattern: pattern)
      end

      @users = scope
    end

    def update
      new_role = user_params[:role]

      if demoting_last_admin?(@user, new_role)
        redirect_to admin_users_path(role: params[:role], q: params[:q]), alert: "마지막 관리자 계정은 다른 역할로 변경할 수 없습니다."
        return
      end

      if @user.update(user_params)
        redirect_to admin_users_path(role: params[:role], q: params[:q]), notice: "#{@user.name} 계정의 역할을 변경했습니다."
      else
        redirect_to admin_users_path(role: params[:role], q: params[:q]), alert: @user.errors.full_messages.join(", ")
      end
    end

    def destroy
      if @user == current_user
        redirect_to admin_users_path(role: params[:role], q: params[:q]), alert: "현재 로그인한 관리자 계정은 삭제할 수 없습니다."
        return
      end

      if @user.admin? && User.where(role: :admin).count == 1
        redirect_to admin_users_path(role: params[:role], q: params[:q]), alert: "마지막 관리자 계정은 삭제할 수 없습니다."
        return
      end

      user_name = @user.name
      @user.destroy!
      redirect_to admin_users_path(role: params[:role], q: params[:q]), notice: "#{user_name} 계정을 삭제했습니다."
    end

    private

    def set_user
      @user = User.find(params[:id])
    end

    def user_params
      params.require(:user).permit(:role)
    end

    def demoting_last_admin?(user, new_role)
      user.admin? && new_role != "admin" && User.where(role: :admin).count == 1
    end
  end
end
