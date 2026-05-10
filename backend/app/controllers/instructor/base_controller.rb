module Instructor
  class BaseController < ApplicationController
    before_action :require_instructor_access!

    private

    def require_instructor_access!
      return if current_user&.instructor?

      respond_to do |format|
        format.html { redirect_to instructor_access_denied_path }
        format.json { render json: { error: "Instructor access required" }, status: :forbidden }
      end
    end
  end
end
