class JwtService
  ALGORITHM = "HS256"
  EXPIRY = 24.hours

  def self.encode(payload)
    payload = payload.merge(exp: EXPIRY.from_now.to_i)
    JWT.encode(payload, secret, ALGORITHM)
  end

  def self.decode(token)
    decoded = JWT.decode(token, secret, true, { algorithm: ALGORITHM })
    HashWithIndifferentAccess.new(decoded.first)
  rescue JWT::DecodeError, JWT::ExpiredSignature, JWT::VerificationError
    nil
  end

  def self.secret
    Rails.application.secret_key_base.presence || ENV["SECRET_KEY_BASE"].presence
  end
  private_class_method :secret
end
