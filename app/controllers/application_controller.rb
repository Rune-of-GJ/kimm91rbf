class ApplicationController < ActionController::Base
  private

  def current_user
    @current_user ||= User.find_by(id: session[:user_id])
  end

  def require_login!
    return if current_user

    render json: { error: "Authentication required" }, status: :unauthorized
  end
end
