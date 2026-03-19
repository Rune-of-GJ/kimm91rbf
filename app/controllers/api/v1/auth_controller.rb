module Api
  module V1
    class AuthController < BaseController
      def signup
        user = User.new(signup_params)

        if user.save
          session[:user_id] = user.id
          render json: user_payload(user), status: :created
        else
          render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def login
        user = User.find_by(email: params[:email])

        if user&.authenticate(params[:password])
          session[:user_id] = user.id
          render json: {
            user: user_payload(user),
            token_type: "Session",
            expires_in: 3600
          }, status: :ok
        else
          render json: { error: "Invalid email or password" }, status: :unauthorized
        end
      end

      def refresh
        return render json: { error: "Authentication required" }, status: :unauthorized unless current_user

        render json: {
          user: user_payload(current_user),
          token_type: "Session",
          expires_in: 3600
        }, status: :ok
      end

      def logout
        reset_session
        head :no_content
      end

      private

      def signup_params
        params.permit(:email, :password, :name)
      end

      def user_payload(user)
        {
          id: user.id,
          email: user.email,
          name: user.name,
          role: user.role,
          created_at: user.created_at
        }
      end
    end
  end
end
