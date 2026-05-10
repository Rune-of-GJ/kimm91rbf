module Preview
  module Student
    class CoachingController < ApplicationController
      before_action :set_coaching_preview

      def products; end

      def request_form; end

      def requests; end

      def request_complete; end

      private

      def set_coaching_preview
        @coaching_products = [
          {
            name: "1:1 첨삭 1회권",
            price: 29000,
            credits: 1,
            pitch: "한 번 빠르게 피드백을 받아보고 싶은 학생용"
          },
          {
            name: "1:1 첨삭 3회 패키지",
            price: 79000,
            credits: 3,
            pitch: "발표나 면접을 여러 번 다듬고 싶은 학생용"
          },
          {
            name: "면접 집중 첨삭",
            price: 49000,
            credits: 1,
            pitch: "실전 질문 대응과 전달력까지 같이 보는 집중 피드백"
          }
        ]

        @active_membership = {
          plan: "Coach",
          included_credits: 2,
          remaining_credits: 1,
          renews_on: 1.month.from_now.to_date
        }

        @feedback_requests = [
          {
            title: "면접 자기소개 리허설",
            status: "피드백 도착",
            submitted_on: Date.current - 2.days,
            credit_source: "Coach 포함 1회"
          },
          {
            title: "발표 도입부 톤 점검",
            status: "검토 중",
            submitted_on: Date.current - 1.day,
            credit_source: "별도 구매권 1회"
          }
        ]
      end
    end
  end
end
