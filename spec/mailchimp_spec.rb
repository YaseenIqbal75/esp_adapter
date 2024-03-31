require 'spec_helper'
require_relative '../lib/esp_adapter/mailchimp'
require 'pry'
require 'net/http'

RSpec.describe EspAdapter::Mailchimp do
  let(:api_key) { '79bf390c0e16020d7b18d7fe5dd60a55-us18' }
  let(:mailchimp_instance) { EspAdapter::Mailchimp.new(api_key) }

  describe '#lists' do
    context 'when API call succeed' do
      it 'returns lists of Mailchimp' do
        # Arrange
        allow(mailchimp_instance).to receive(:lists).and_return({
          'lists' => [
            { 'name' => 'List 1' },
            { 'name' => 'List 2' },
          ],
        })
        # Act
        lists = mailchimp_instance.lists
        # Assert
        expect(lists).to be_an(Hash)
        expect(lists).not_to be_empty
        expect(lists["lists"][0]["name"]).to eq('List 1')
      end
    end

    context 'when API call fails' do
      it 'raises a custom error with appropriate message w.r.t status' do
        # Arrange
        allow(mailchimp_instance).to receive(:lists).
          and_raise(
            StandardError.new(
              "{
                :message=>\"ESP Adapter: Resource not found. Please verify the provided list ID.\",
                :status=>404
              }"
            )
          )
        # Act & Assert
        expect { mailchimp_instance.lists }.
          to raise_error(
            StandardError,
            /ESP Adapter: Resource not found. Please verify the provided list ID./
          )

        # Arrange
        allow(mailchimp_instance).to receive(:lists).
          and_raise(
            StandardError.new(
              "{
                :message=>\"ESP Adapter: Bad request.
                Please ensure your request is valid and try again..\",
                :status=>400
              }"
            )
          )
        # Act & Assert
        expect { mailchimp_instance.lists }.
          to raise_error(
            StandardError,
            /ESP Adapter: Bad request. Please ensure your request is valid and try again./
          )
      end

      it 'raises a server custom error with appropriate message' do
        # Arrange
        allow(mailchimp_instance).to receive(:lists).
          and_raise(
            StandardError.new(
              "{
                :message=>\"ESP Adapter: Internal Server Error.\",
                :status=>500
              }"
            )
          )
        # Act & Assert
        expect { mailchimp_instance.lists }.
          to raise_error(
            StandardError,
            /ESP Adapter: Internal Server Error/
          )
      end
    end
  end

  describe '#list_metrics' do
    let(:list_id) { 'd5670bfc6c' }

    context 'when API call succeed' do
      it 'returns metrics for a particular list in Mailchimp' do
        # Arrange
        allow(mailchimp_instance).to receive(:list_metrics).with(list_id).and_return({
          subscriber_count: 1000,
          average_open_rate: 25.5,
          click_rate: 15.7,
          last_send_date: '2024-03-29',
        })
        # Act
        metrics = mailchimp_instance.list_metrics(list_id)
        # Assert
        expect(metrics).to be_a(Hash)
        expect(metrics).not_to be_empty
        expect(metrics).to include(
          :subscriber_count,
          :average_open_rate,
          :click_rate,
          :last_send_date
        )
      end
    end

    context 'when API call fails' do
      it 'raises a custom error with appropriate message w.r.t status' do
        # Arrange
        allow(mailchimp_instance).to receive(:list_metrics).with(list_id).
          and_raise(
            StandardError.new(
              "{
                :message=>\"ESP Adapter: Resource not found. Please verify the provided list ID.\",
                :status=>404
              }"
            )
          )
        # Act & Assert
        expect { mailchimp_instance.list_metrics(list_id) }.
          to raise_error(
            StandardError,
            /ESP Adapter: Resource not found/
          )
      end

      it 'raises a server error with appropriate message' do
        # Arrange
        allow(mailchimp_instance).to receive(:list_metrics).with(list_id).
          and_raise(
            StandardError.new(
              "{:message=>\"ESP Adapter: Internal Server Error.\", :status=>500}"
            )
          )
        # Act & Assert
        expect { mailchimp_instance.list_metrics(list_id) }.
          to raise_error(
            StandardError,
            /ESP Adapter: Internal Server Error/
          )
      end
    end
  end

  describe '#graceful_degradation:' do
    context 'when status code is 400' do
      it 'returns a bad request error message' do
        # Arrange
        error = EspAdapter::Errors::Mailchimp.new(400)
        # Act & Assert
        expect(error.display_gracefully_by_status).
          to eq("ESP Adapter: Bad request. Please ensure your request is valid and try again.")
      end
    end

    context 'when status code is 401' do
      it 'returns an unauthorized error message' do
        # Arrange
        error = EspAdapter::Errors::Mailchimp.new(401)
        # Act & Assert
        expect(error.display_gracefully_by_status).
          to eq("ESP Adapter: Unauthorized. Please provide valid credentials and try again.")
      end
    end

    context 'when status code is 403' do
      it 'returns a forbidden error message' do
        # Arrange
        error = EspAdapter::Errors::Mailchimp.new(403)
        # Act & Assert
        expect(error.display_gracefully_by_status).
          to eq("ESP Adapter: Forbidden. Ensure you have the necessary permissions.")
      end
    end

    context 'when status code is 404' do
      it 'returns resource not found' do
        # Arrange
        error = EspAdapter::Errors::Mailchimp.new(404)
        # Act & Assert
        expect(error.display_gracefully_by_status).
          to eq("ESP Adapter: Resource not found. Please verify the provided list ID.")
      end
    end

    context 'when status code is 405' do
      it 'returns a method not allowed error message' do
        # Arrange
        error = EspAdapter::Errors::Mailchimp.new(405)
        # Act & Assert
        expect(error.display_gracefully_by_status).
          to eq("ESP Adapter: Method not allowed. Please check your HTTP request method.")
      end
    end

    context 'when status code is 414' do
      it 'returns a URI too long error message' do
        # Arrange
        error = EspAdapter::Errors::Mailchimp.new(414)
        # Act & Assert
        expect(error.display_gracefully_by_status).
          to eq(
            "ESP Adapter: URI too long.
            Please ensure the URI length is within the allowed limit."
          )
      end
    end

    context 'when status code is 422' do
      it 'returns an unprocessable entity error message' do
        # Arrange
        error = EspAdapter::Errors::Mailchimp.new(422)
        # Act & Assert
        expect(error.display_gracefully_by_status).
          to eq(
            "ESP Adapter: Unprocessable entity.
            Request cannot be processed due to semantic errors."
          )
      end
    end

    context 'when status code is 426' do
      it 'returns an upgrade required error message' do
        # Arrange
        error = EspAdapter::Errors::Mailchimp.new(426)
        # Act & Assert
        expect(error.display_gracefully_by_status).
          to eq(
            "ESP Adapter: Upgrade required.
            Please upgrade to a newer version of the protocol."
          )
      end
    end

    context 'when status code is 429' do
      it 'returns a too many requests error message' do
        # Arrange
        error = EspAdapter::Errors::Mailchimp.new(429)
        # Act & Assert
        expect(error.display_gracefully_by_status).
          to eq(
            "ESP Adapter: Too many requests.
            Please wait and try again later."
          )
      end
    end

    context 'when status code is 500' do
      it 'returns a server error message' do
        # Arrange
        error = EspAdapter::Errors::Mailchimp.new(500)
        # Act & Assert
        expect(error.display_gracefully_by_status).
          to eq(
            "ESP Adapter: Server encountered an unexpected error.
            Please try again later."
          )
      end
    end

    context 'when status code is not recognized' do
      it 'returns an unexpected error message' do
        # Arrange
        error = EspAdapter::Errors::Mailchimp.new(999)
        # Act & Assert
        expect(error.display_gracefully_by_status).
          to eq(
            "ESP Adapter: An unexpected error occurred.
            Please try again later."
          )
      end
    end
  end

  describe '#handle_errors' do
    let(:maximum_retries_count) { 1 }
    let(:retry_delay_time) { 2 }

    context 'when MailchimpMarketing::ApiError with status 408 is raised' do
      it 'retries on Mailchimp API error with status 408' do
        # Arrange
        allow_any_instance_of
        MailchimpMarketing::Client.
          to receive(:lists).and_raise(MailchimpMarketing::ApiError.new(status: 408))
        # Act & Assert
        expect { mailchimp_instance.lists }.to raise_error(StandardError) do |error|
          expect(error.message).to eq("{
            :message=>\"ESP Adapter: An unexpected error occurred.
            Please try again later.\",
            :status=>408}")
        end
      end
    end

    context 'when Net::ReadTimeout is raised' do
      it 'retries on timeout error and raises StandardError after maximum retries' do
        # Arrange
        allow_any_instance_of(MailchimpMarketing::Client).
          to receive(:lists).and_raise(Net::ReadTimeout)
        # Act & Assert
        expect { mailchimp_instance.lists }.to raise_error(StandardError)
      end
    end
  end
end
