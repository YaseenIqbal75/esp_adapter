# frozen_string_literal: true

# lib/esp_adapter/mailchimp.rb
require_relative 'base'
require 'MailchimpMarketing'

module EspAdapter
  class Mailchimp < Base
    MAXIMUM_RETRIES_COUNT = 1
    RETRY_DELAY_TIME = 2
    def initialize(api_key)
      super(api_key)
      # Initialize the Mailchimp API client
      @client = MailchimpMarketing::Client.new(api_key: @api_key)
    end

    # Returns an array of String with all the newsletter names
    def lists
      handle_errors do
        response = @client.lists.get_all_lists
        response['lists'].map { |list| list['name'] } if response.present?
      end
    end

    # Returns metrics for a particular newsletter in Mailchimp
    def list_metrics(list_id)
      handle_errors do
        stats = @client.lists.get_list(list_id)['stats']
        {
          subscriber_count: stats['member_count'],
          average_open_rate: stats['open_rate'],
          click_rate: stats['click_rate'],
          last_send_date: stats['last_sub_date'],
        }
      end
    end

    private

    # Handle resiliency
    def handle_errors
      attempts = 0
      begin
        yield
      rescue MailchimpMarketing::ApiError => e
        attempts += 1
        if attempts <= MAXIMUM_RETRIES_COUNT && e.status == 408
          sleep RETRY_DELAY_TIME
          retry
        else
          raise StandardError, {
            message: EspAdapter::Errors::Mailchimp.new(e.status).display_gracefully_by_status,
            status: e.status,
          }
        end
      rescue StandardError => e
        attempts += 1
        if attempts <= MAXIMUM_RETRIES_COUNT && e&.is_a?(Net::ReadTimeout)
          sleep RETRY_DELAY_TIME
          retry
        else
          raise StandardError, {
            message: EspAdapter::Errors::Mailchimp.new(500).display_gracefully_by_status,
            status: 500,
          }
        end
      end
    end
  end
end
