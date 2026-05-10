module Preview
  module Student
    class CommerceController < ApplicationController
      PreviewCourse = Struct.new(:id, :title, :description, :instructor_name, :category, :lectures, keyword_init: true)
      PreviewCategory = Struct.new(:name, keyword_init: true)

      before_action :set_preview_catalog

      def course_detail; end

      def cart
        @cart_items = @priced_courses.first(2)
        @cart_subtotal = @cart_items.sum { |item| item[:price] }
        @cart_discount = 12000
        @cart_total = @cart_subtotal - @cart_discount
      end

      def checkout
        @cart_items = @priced_courses.first(2)
        @checkout_subtotal = @cart_items.sum { |item| item[:price] }
        @checkout_discount = 12000
        @checkout_total = @checkout_subtotal - @checkout_discount
        @checkout_methods = [
          { label: "카드 결제", note: "가장 일반적인 구매 흐름" },
          { label: "간편 결제", note: "카카오페이, 네이버페이 같은 빠른 결제" },
          { label: "쿠폰/프로모션", note: "강의 할인권과 기간 한정 혜택 적용" }
        ]
      end

      def order_complete
        @purchased_courses = @priced_courses.first(2)
        @completed_amount = @purchased_courses.sum { |item| item[:price] } - 12000
      end

      private

      def set_preview_catalog
        courses = Course.includes(:category, :lectures).order(created_at: :desc).limit(4)

        fallback_courses = courses.to_a
        while fallback_courses.size < 4
          index = fallback_courses.size + 1
          fallback_courses << PreviewCourse.new(
            id: 10_000 + index,
            title: "스피치 코스 #{index}",
            description: "SpeakFlow 유료 강의 흐름을 확인하기 위한 테스트용 설명입니다.",
            instructor_name: "테스트 강사",
            category: PreviewCategory.new(name: "Speaking"),
            lectures: Array.new(6) { Object.new }
          )
        end

        prices = [79000, 119000, 149000, 189000]
        badges = ["추천", "집중 훈련", "1:1 피드백 포함", "실전 대비"]

        @priced_courses = fallback_courses.first(4).each_with_index.map do |course, index|
          {
            course: course,
            price: prices[index],
            original_price: prices[index] + 30000,
            badge: badges[index],
            lecture_count: course.lectures.size,
            ownership: "결제 후 무제한 소장",
            support: index.even? ? "리허설 과제 포함" : "강사 피드백 포함"
          }
        end

        @featured_course = @priced_courses.first
      end
    end
  end
end
