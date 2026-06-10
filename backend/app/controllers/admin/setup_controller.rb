module Admin
  class SetupController < ApplicationController
    before_action :redirect_if_admin_exists

    def new
      @admin_user = User.new
    end

    def create
      @admin_user = User.new(admin_user_params.merge(role: :admin))

      if @admin_user.save
        set_jwt_cookie(@admin_user)
        redirect_to admin_dashboard_path, notice: "첫 관리자 계정을 생성했습니다."
      else
        render :new, status: :unprocessable_entity
      end
    end

    private

    def redirect_if_admin_exists
      return unless User.where(role: :admin).exists?

      redirect_to login_path, alert: "관리자 계정은 이미 설정되어 있습니다."
    end

    def admin_user_params
      params.require(:user).permit(:name, :email, :password)
    end

  end
end
