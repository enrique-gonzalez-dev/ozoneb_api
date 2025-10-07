class JsonWebToken
  HMAC_SECRET = Rails.application.credentials.secret_key_base || '8b4a1f491f6d66efeeeaa400c20977829810c49f12a71f7db6588d96de39a69d8d8da5a78c5a0db9b5a34176bc17efe10b0682147a8c76f8924823ed88af8fe2'

  def self.encode(payload, exp = 24.hours.from_now)
    payload[:exp] = exp.to_i
    JWT.encode(payload, HMAC_SECRET)
  end

  def self.decode(token)
    decoded = JWT.decode(token, HMAC_SECRET)[0]
    HashWithIndifferentAccess.new decoded
  rescue JWT::DecodeError
    nil
  end
end
