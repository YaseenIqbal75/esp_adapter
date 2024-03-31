# frozen_string_literal: true

# lib/esp_adapter/base.rb
module EspAdapter
  # Base class for ESP adapters.
  
  Dir[File.join(__dir__, 'errors', '*.rb')].each { |file| require file }

  class Base
    def initialize(api_key)
      @api_key = api_key
    end

    def lists
      handle_errors do
      end
    end

    def list_metrics(_list_id)
      handle_errors do
      end
    end

    private

    def handle_errors
      yield
    rescue StandardError => e
      raise CustomError, "An error has occurred while performing action: #{e.message}"
    end
  end
end
