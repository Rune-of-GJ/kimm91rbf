module Api
  module V1
    class BaseController < ApplicationController
      skip_forgery_protection
      before_action :set_default_format

      private

      def set_default_format
        request.format = :json
      end
    end
  end
end
