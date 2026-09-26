class JsonWebToken
  SECRET_KEY = Rails.application.secret_key_base

  # Genera el token guardando el user_id con expiración (ej. 24 horas)
  def self.encode(payload, exp = 24.hours.from_now)
    payload[:exp] = exp.to_i
    JWT.encode(payload, SECRET_KEY)
  end

  # Decodifica y verifica la firma del token enviado
  def self.decode(token)
    decoded = JWT.decode(token, SECRET_KEY)[0]
    HashWithIndifferentAccess.new decoded
  rescue JWT::DecodeError, JWT::ExpiredSignature
    nil
  end
end