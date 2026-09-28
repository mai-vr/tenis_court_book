class Api::V1::UsersController < Api::V1::BaseController
    def create
        @user = User.new(user_params)

        if @user.save 
            token = JsonWebToken.encode(user_id: @user.id)

            render json: {
            message: "Usuario registrado con éxito.",
            token: token,
            user: {
              id: @user.id,
              email: @user.email_address,
              first_name: @user.first_name,
              last_name: @user.last_name
            }
          }, status: :created
        else
          render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
        end
    end

    private

    def user_params
        params.permit(:first_name, :last_name, :email_address, :password, :password_confirmation)
    end
end