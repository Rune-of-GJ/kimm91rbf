module Preview
  module Admin
    class AdminController < ApplicationController
      before_action :set_preview_data
      before_action :prepare_user_preview, only: :users
      before_action :prepare_account_preview, only: :account
      before_action :prepare_policy_preview, only: :policy
      before_action :prepare_settlement_preview, only: [:settlement_membership, :settlement_coaching, :settlement_instructors]

      def dashboard; end

      def entry; end

      def account; end

      def policy; end

      def users; end

      def courses; end

      def settlement_membership; end

      def settlement_coaching; end

      def settlement_instructors; end

      private

      def set_preview_data
        @preview_counts = {
          users: User.count,
          admins: User.where(role: :admin).count,
          instructors: User.where(role: :instructor).count,
          students: User.where(role: :student).count,
          courses: Course.count,
          categories: Category.count
        }

        @preview_users = User.order(created_at: :desc)
        @preview_courses = Course.includes(:category, :lectures, :instructor).order(created_at: :desc).limit(10)
        @recent_users = @preview_users.limit(5)
        @recent_courses = @preview_courses.first(5)
      end

      def prepare_account_preview
        @promotable_users = User.where(role: [:instructor, :student]).order(created_at: :desc).limit(8)
      end

      def prepare_user_preview
        @preview_role = params[:role].presence_in(%w[all admin instructor student]) || "all"
        @preview_query = params[:q].to_s.strip

        @user_role_counts = {
          "all" => User.count,
          "admin" => User.where(role: :admin).count,
          "instructor" => User.where(role: :instructor).count,
          "student" => User.where(role: :student).count
        }

        scope = User.includes(:enrollments, :instructed_courses).order(created_at: :desc)
        scope = scope.where(role: @preview_role) unless @preview_role == "all"

        if @preview_query.present?
          pattern = "%#{ActiveRecord::Base.sanitize_sql_like(@preview_query)}%"
          scope = scope.where("name LIKE :pattern OR email LIKE :pattern", pattern: pattern)
        end

        @filtered_users = scope
      end

      def prepare_policy_preview
        @policy_role = params[:as].presence_in(%w[guest student instructor admin]) || "guest"

        @policy_state = {
          "guest" => {
            label: "비로그인 사용자",
            allowed: false,
            message: "관리자 페이지는 비로그인 상태에서 접근할 수 없습니다."
          },
          "student" => {
            label: "수강생 계정",
            allowed: false,
            message: "관리자 페이지는 수강생 계정에서 접근할 수 없습니다."
          },
          "instructor" => {
            label: "강사 계정",
            allowed: false,
            message: "관리자 페이지는 강사 계정에서 접근할 수 없습니다."
          },
          "admin" => {
            label: "관리자 계정",
            allowed: true,
            message: "관리자 계정은 관리자 페이지에 정상적으로 접속할 수 있습니다."
          }
        }[@policy_role]

        @blocked_responses = [
          {
            title: "에러 페이지로 이동",
            body: "비로그인, 강사, 수강생이 관리자 URL에 진입하면 권한 없음 전용 에러 페이지로 이동시키는 방식입니다."
          },
          {
            title: "alert 후 이전 페이지로 복귀",
            body: "권한이 없다는 alert를 보여준 뒤, 직전 페이지 또는 메인으로 돌려보내는 방식입니다."
          }
        ]
      end

      def prepare_settlement_preview
        @settlement_month = Date.current.prev_month.strftime("%Y.%m")
        @subscription_revenue = 12_480_000
        @refund_amount = 620_000
        @pg_fee_amount = 318_000
        @tax_amount = 1_154_000
        @other_deduction_amount = 88_000
        @settlement_revenue = @subscription_revenue - @refund_amount - @pg_fee_amount - @tax_amount - @other_deduction_amount
        @instructor_pool_rate = 0.6
        @instructor_pool_amount = (@settlement_revenue * @instructor_pool_rate).round
        @total_valid_watch_minutes = 18_600
        @minimum_watch_minutes = 60
        @minimum_payout_amount = 10_000

        @watch_contributions = [
          { instructor: "김강사", minutes: 7_420, share: 39.9, payout: 4_124_000, eligible: true },
          { instructor: "박강사", minutes: 5_860, share: 31.5, payout: 3_257_000, eligible: true },
          { instructor: "이강사", minutes: 3_980, share: 21.4, payout: 2_213_000, eligible: true },
          { instructor: "신강사", minutes: 940, share: 5.1, payout: 528_000, eligible: true },
          { instructor: "오강사", minutes: 400, share: 2.1, payout: 0, eligible: false }
        ]

        @coaching_sales_total = 1_920_000
        @coaching_platform_fee = (@coaching_sales_total * 0.1).round
        @coaching_instructor_total = @coaching_sales_total - @coaching_platform_fee

        @coaching_settlements = [
          { instructor: "김강사", completed_requests: 11, gross: 660_000, platform_fee: 66_000, payout: 594_000 },
          { instructor: "박강사", completed_requests: 9, gross: 540_000, platform_fee: 54_000, payout: 486_000 },
          { instructor: "이강사", completed_requests: 6, gross: 360_000, platform_fee: 36_000, payout: 324_000 },
          { instructor: "신강사", completed_requests: 3, gross: 180_000, platform_fee: 18_000, payout: 162_000 },
          { instructor: "오강사", completed_requests: 3, gross: 180_000, platform_fee: 18_000, payout: 162_000 }
        ]

        @settlement_overview = [
          {
            instructor: "김강사",
            membership_payout: 4_124_000,
            coaching_payout: 594_000,
            hold_amount: 0,
            final_payout: 4_718_000,
            status: "승인 대기"
          },
          {
            instructor: "박강사",
            membership_payout: 3_257_000,
            coaching_payout: 486_000,
            hold_amount: 0,
            final_payout: 3_743_000,
            status: "승인 대기"
          },
          {
            instructor: "이강사",
            membership_payout: 2_213_000,
            coaching_payout: 324_000,
            hold_amount: 0,
            final_payout: 2_537_000,
            status: "승인 대기"
          },
          {
            instructor: "신강사",
            membership_payout: 528_000,
            coaching_payout: 162_000,
            hold_amount: 0,
            final_payout: 690_000,
            status: "승인 대기"
          },
          {
            instructor: "오강사",
            membership_payout: 0,
            coaching_payout: 162_000,
            hold_amount: 162_000,
            final_payout: 0,
            status: "이월"
          }
        ]
      end
    end
  end
end
