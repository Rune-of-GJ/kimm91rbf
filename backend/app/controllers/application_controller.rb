class ApplicationController < ActionController::Base
  helper_method :current_user

  private

  def current_user
    @current_user ||= begin
      token = cookies[:jwt_token]
      if token
        payload = JwtService.decode(token)
        User.find_by(id: payload[:user_id]) if payload
      end
    end
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
