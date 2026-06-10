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

    redirect_to login_path(return_to: request.fullpath), alert: "로그인이 필요합니다."
  end

  def set_jwt_cookie(user)
    token = JwtService.encode(user_id: user.id)
    cookies[:jwt_token] = {
      value: token,
      httponly: true,
      expires: 24.hours.from_now,
      secure: secure_cookie?,
      same_site: :lax
    }
  end

  def secure_cookie?
    request.headers["X-Forwarded-Proto"].to_s.split(",").first.to_s.strip == "https"
  end
end
