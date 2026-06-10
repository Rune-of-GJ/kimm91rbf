module Api
  module V1
    class AuthController < BaseController
      def signup
        user = User.new(signup_params)

        if user.save
          set_jwt_cookie(user)
          respond_to do |format|
            format.html { redirect_to root_path, notice: "회원가입이 완료되었습니다." }
            format.json { render json: { user: user_payload(user) }, status: :created }
          end
        else
          respond_to do |format|
            format.html { redirect_to login_path, alert: user.errors.full_messages.join(", ") }
            format.json { render json: { errors: user.errors.full_messages }, status: :unprocessable_entity }
          end
        end
      end

      def login
        email = params.require(:email).to_s.strip.downcase
        password = params.require(:password)
        user = User.find_by(email: email)

        if user&.authenticate(password)
          set_jwt_cookie(user)
          respond_to do |format|
            format.html { redirect_to root_path, notice: "로그인되었습니다." }
            format.json do
              render json: {
                user: user_payload(user),
                token_type: "JWT",
                expires_in: 86400
              }, status: :ok
            end
          end
        else
          respond_to do |format|
            format.html { redirect_to login_path, alert: "이메일 또는 비밀번호가 잘못되었습니다." }
            format.json { render json: { error: "Invalid email or password" }, status: :unauthorized }
          end
        end
      end

      def refresh
        return render json: { error: "Authentication required" }, status: :unauthorized unless current_user

        set_jwt_cookie(current_user)
        render json: {
          user: user_payload(current_user),
          token_type: "JWT",
          expires_in: 86400
        }, status: :ok
      end

      def logout
        cookies.delete(:jwt_token)
        reset_session
        respond_to do |format|
          format.html { redirect_to root_path, notice: "로그아웃되었습니다." }
          format.json { head :no_content }
        end
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
