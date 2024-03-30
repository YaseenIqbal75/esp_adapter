# frozen_string_literal: true

# lib/esp_adapter/base.rb
module EspAdapter
  # Base class for ESP adapters.
  # This class defines common functionalities and serves as a foundation
  # for specific ESP adapter implementations.

  Dir[File.join(__dir__, 'errors', '*.rb')].each { |file| require file }

  class Base
    def initialize(api_key)
      @api_key = api_key
    end

    def lists
      handle_errors do
        # logic to fetch lists
      end
    end

    def list_metrics(_list_id)
      handle_errors do
        # logic to get metrics end
      end
    end

    private

    def handle_errors
      yield
    rescue StandardError => e
      # log errror
      raise CustomError, "An error has occurred while performing action: #{e.message}"
    end
  end
end
