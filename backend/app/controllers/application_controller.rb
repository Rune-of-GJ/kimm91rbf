class ApplicationController < ActionController::Base
  helper_method :current_user

  private

  def current_user
    @current_user ||= User.find_by(id: session[:user_id])
  end

  def require_login!
    return if current_user

    render json: { error: "Authentication required" }, status: :unauthorized
  end

  def require_login_for_html!
    return if current_user

    redirect_to login_path, alert: "로그인이 필요합니다."
  end
end
