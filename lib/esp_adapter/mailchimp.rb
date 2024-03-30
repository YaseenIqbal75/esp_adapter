# frozen_string_literal: true

# lib/esp_adapter/mailchimp.rb
require_relative 'base'
require 'MailchimpMarketing'

module EspAdapter
  class Mailchimp < Base
    MAX_RETRIES = 3
    RETRY_DELAY = 5
    def initialize(api_key)
      super(api_key)
      # Initialize the Mailchimp API client
      @client = MailchimpMarketing::Client.new(api_key: @api_key)
    end

    # Returns an Array of String with all the newsletter names
    def lists
      handle_errors do
        response = @client.lists.get_all_lists
        response['lists'].map { |list| list['name'] }
      end
    end

    # @return [Hash] with metrics for the newsletter
    def list_metrics(list_id)
      handle_errors do
        stats = @client.lists.get_list(list_id)['stats']
        {
          # Number of subscribers to the newsletter
          subscriber_count: stats['member_count'],
          # Average open rate for the newsletter
          average_open_rate: stats['open_rate'],
          # Average click rate for the newsletter
          click_rate: stats['click_rate'],
          # Date of the last newsletter send
          last_send_date: stats['last_sub_date'],
        }
      end
    end

    # Handle Mailchimp API errors and retry failed requests if necessary
    def handle_errors
      yield
    rescue MailchimpMarketing::ApiError => e
      # Mailchimp API error - raise a custom error with a message and status
      raise StandardError, {
        message: EspAdapter::Errors::Mailchimp.new(e.status).display_gracefully_by_status,
        status: e.status,
      }
    rescue StandardError
      # Standard error - raise a custom error with a message and status 500
      raise StandardError, {
        message: EspAdapter::Errors::Mailchimp.new(500).display_gracefully_by_status,
        status: 500,
      }
    end
  end
end
