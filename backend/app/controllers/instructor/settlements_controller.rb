module Instructor
  class SettlementsController < BaseController
    before_action :set_counts
    before_action :set_settlement_report

    def index
      @instructor_settlement = @settlement_report.instructor_report(current_user)
    end

    def month
      @instructor_settlement = @settlement_report.instructor_report(current_user)
    end

    private

    def set_counts
      scope = current_user.instructed_courses
      @instructor_counts = {
        courses: scope.count,
        categories: Category.count,
        upcoming: scope.where("start_date >= ?", Date.current).count
      }
    end

    def set_settlement_report
      @settlement_report = SettlementReportBuilder.new(month: selected_month)
      @settlement_month = selected_month
    end

    def selected_month
      @selected_month ||= begin
        Date.strptime(params[:month], "%Y-%m")
      rescue ArgumentError, TypeError
        Date.current.beginning_of_month
      end
    end
  end
end
