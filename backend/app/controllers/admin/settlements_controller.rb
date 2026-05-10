module Admin
  class SettlementsController < BaseController
    before_action :set_settlement_report

    def membership
      @membership_report = @settlement_report.membership_report
    end

    def coaching
      @coaching_report = @settlement_report.coaching_report
    end

    def instructors
      @settlement_rows = @settlement_report.instructor_summary_rows
    end

    private

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
