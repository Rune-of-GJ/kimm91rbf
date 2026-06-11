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

  def confirm_toss_payment(payment_key, order_id, amount)
    uri = URI("https://api.tosspayments.com/v1/payments/confirm")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.read_timeout = 10

    credentials = Base64.strict_encode64("#{ENV.fetch('TOSS_SECRET_KEY', '')}:")
    req = Net::HTTP::Post.new(uri.path, {
      "Content-Type" => "application/json",
      "Authorization" => "Basic #{credentials}"
    })
    req.body = { paymentKey: payment_key, orderId: order_id, amount: amount }.to_json

    res = http.request(req)
    data = JSON.parse(res.body)
    res.is_a?(Net::HTTPSuccess) && data["status"] == "DONE"
  rescue => e
    Rails.logger.error "Toss confirm error: #{e.message}"
    false
  end
end
