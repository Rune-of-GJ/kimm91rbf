module Api
  module V1
    class BaseController < ApplicationController
      skip_forgery_protection
      before_action :set_default_format

      rescue_from ActiveRecord::RecordNotFound, with: :render_not_found
      rescue_from ActionController::ParameterMissing, with: :render_bad_request

      private

      def set_default_format
        request.format = :json
      end

      def enrolled_in_course?(course)
        current_user&.enrollments&.exists?(course_id: course.id)
      end

      def render_not_found(exception)
        message = exception.model ? "#{exception.model} not found" : "Resource not found"
        render json: { error: message }, status: :not_found
      end

      def render_bad_request(exception)
        render json: { error: exception.message }, status: :bad_request
      end
    end
  end
end
