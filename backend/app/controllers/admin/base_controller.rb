module Admin
  class BaseController < ApplicationController
    before_action :redirect_to_setup_if_needed
    before_action :require_admin_access!

    private

    def redirect_to_setup_if_needed
      return if User.where(role: :admin).exists?

      redirect_to admin_setup_path
    end

    def require_admin_access!
      return if current_user&.admin?

      respond_to do |format|
        format.html { redirect_to admin_access_denied_path }
        format.json { render json: { error: "Admin access required" }, status: :forbidden }
      end
    end
  end
end
