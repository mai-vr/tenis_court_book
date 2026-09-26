class Api::V1::BaseController < ActionController::API
    rescue_from ActiveRecord::RecordNotFound, with: :not_found

    private 
    
    def authenticate_request!
        render json: { error: "No autorizado. Token faltante o inválido." }, status: :unauthorized unless current_user
    end

      # Obtiene el usuario decodificando el Header Authorization
      def current_user
        @current_user ||= begin
          header = request.headers["Authorization"]
          return nil if header.blank?

          # El formato del header suele ser "Bearer <token>"
          token = header.split(" ").last
          decoded = JsonWebToken.decode(token)

          User.find_by(id: decoded[:user_id]) if decoded
        end
      end

      def not_found(exception)
        render json: { error: exception.message }, status: :not_found
      end
end