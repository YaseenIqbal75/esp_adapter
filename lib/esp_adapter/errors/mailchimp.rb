module EspAdapter
  module Errors
    class Mailchimp
      def initialize(status_code)
        @status_code = status_code
      end

      def display_gracefully_by_status
        case @status_code
        when 400
          "ESP Adapter: Bad request. Please ensure your request is valid and try again."
        when 401
          "ESP Adapter: Unauthorized. Please provide valid credentials and try again."
        when 403
          "ESP Adapter: Forbidden. Ensure you have the necessary permissions."
        when 404
          "ESP Adapter: Resource not found. Please verify the provided list ID."
        when 405
          "ESP Adapter: Method not allowed. Please check your HTTP request method."
        when 414
          "ESP Adapter: URI too long. Please ensure the URI length is within the allowed limit."
        when 422
          "ESP Adapter: Unprocessable entity. Request cannot be processed due to semantic errors."
        when 426
          "ESP Adapter: Upgrade required. Please upgrade to a newer version of the protocol."
        when 429
          "ESP Adapter: Too many requests. Please wait and try again later."
        when 500
          "ESP Adapter: Server encountered an unexpected error. Please try again later."
        else
          "ESP Adapter: An unexpected error occurred. Please try again later."
        end
      end
    end
  end
end
