class Api::V1::SessionsController < Api::V1::BaseController
    def create
        @user = User.find_by(email_address: params[:email_address] || params[:email])

        if @user&.authenticate(params[:password])
          token = JsonWebToken.encode(user_id: @user.id)
          
          render json: {
            token: token,
            user: {
              id: @user.id,
              email: @user.email_address,
              first_name: @user.first_name,
              last_name: @user.last_name
            }
          }, status: :ok
        else
          render json: { error: "Credenciales inválidas" }, status: :unauthorized
        end
      end
end
