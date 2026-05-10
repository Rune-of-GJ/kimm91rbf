module Preview
  module Instructor
    class SettlementsController < ApplicationController
      before_action :set_settlement_preview

      def index; end

      def month; end

      private

      def set_settlement_preview
        @instructor_name = "김강사"
        @settlement_month = Date.current.prev_month.strftime("%Y.%m")
        @watch_minutes = 7_420
        @watch_share = 39.9
        @membership_gross = 4_124_000
        @coaching_requests = 11
        @coaching_gross = 660_000
        @coaching_fee = 66_000
        @coaching_payout = 594_000
        @hold_threshold = 10_000
        @final_payout = 4_718_000
        @bank_account = "국민은행 1234-56-789012"

        @month_rows = [
          { month: "2026.04", membership: 3_860_000, coaching: 540_000, final: 4_400_000, status: "지급 완료" },
          { month: "2026.05", membership: 4_124_000, coaching: 594_000, final: 4_718_000, status: "승인 대기" },
          { month: "2026.06", membership: 0, coaching: 0, final: 0, status: "집계 전" }
        ]

        @watch_breakdown = [
          { course: "면접 스피치 마스터", minutes: 3_420, share: "46.1%" },
          { course: "발표 전달력 훈련", minutes: 2_860, share: "38.5%" },
          { course: "보이스 컨트롤 베이직", minutes: 1_140, share: "15.4%" }
        ]

        @coaching_breakdown = [
          { product: "1:1 첨삭 1회권", count: 7, gross: 420_000, payout: 378_000 },
          { product: "면접 집중 첨삭", count: 2, gross: 140_000, payout: 126_000 },
          { product: "Coach 포함 첨삭", count: 2, gross: 100_000, payout: 90_000 }
        ]
      end
    end
  end
end
