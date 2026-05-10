module Preview
  module Student
    class MembershipsController < ApplicationController
      before_action :set_membership_preview

      def landing; end

      def plans; end

      def checkout; end

      def account; end

      private

      def set_membership_preview
        @membership_plans = [
          {
            id: "lite",
            name: "Lite",
            price: 19000,
            badge: "입문용",
            pitch: "부담 없이 시작하는 월정액",
            highlights: [
              "기본 스피치 강의 전체 열람",
              "월 4회 리허설 제출",
              "기본 AI 보이스 리포트"
            ]
          },
          {
            id: "pro",
            name: "Pro",
            price: 39000,
            badge: "추천",
            pitch: "연습과 피드백을 꾸준히 이어가는 핵심 플랜",
            highlights: [
              "모든 강의 무제한 열람",
              "월 12회 리허설 제출",
              "강사 코멘트 우선 피드백"
            ]
          },
          {
            id: "coach",
            name: "Coach",
            price: 69000,
            badge: "집중 훈련",
            pitch: "실전 발표와 면접 대비에 맞춘 상위 플랜",
            highlights: [
              "모든 강의 무제한 열람",
              "무제한 리허설 제출",
              "1:1 첨삭 세션 월 2회"
            ]
          }
        ]

        @membership_compare = [
          { feature: "강의 열람", values: ["기본 강의", "전체 강의", "전체 강의"] },
          { feature: "리허설 제출", values: ["월 4회", "월 12회", "무제한"] },
          { feature: "AI 보이스 리포트", values: ["기본", "고급", "고급"] },
          { feature: "강사 피드백", values: ["-", "우선 응답", "집중 피드백"] },
          { feature: "1:1 코칭", values: ["-", "-", "월 2회"] }
        ]

        @selected_plan = @membership_plans.second
        @next_billing_date = 1.month.from_now.to_date
        @active_subscription = {
          plan_name: "Pro",
          status: "활성",
          started_on: Date.current.beginning_of_month,
          renews_on: @next_billing_date,
          monthly_price: 39000
        }
      end
    end
  end
end
