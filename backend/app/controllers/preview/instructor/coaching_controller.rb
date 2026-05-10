module Preview
  module Instructor
    class CoachingController < ApplicationController
      before_action :set_review_preview

      def queue; end

      def review; end

      private

      def set_review_preview
        @queue_items = [
          {
            learner: "김학생",
            title: "면접 자기소개 리허설",
            submitted_on: Date.current - 1.day,
            source: "Coach 포함"
          },
          {
            learner: "박학생",
            title: "발표 도입부 톤 점검",
            submitted_on: Date.current,
            source: "1회권 구매"
          }
        ]

        @review_item = @queue_items.first
      end
    end
  end
end
