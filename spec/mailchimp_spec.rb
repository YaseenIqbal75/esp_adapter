require 'spec_helper'
require_relative '../lib/esp_adapter/mailchimp'
require 'pry'

RSpec.describe EspAdapter::Mailchimp do
  let(:api_key) { '79bf390c0e16020d7b18d7fe5dd60a55-us18' }
  let(:mailchimp_instance) { EspAdapter::Mailchimp.new(api_key) }

  describe '#lists' do
    context 'when API call succeed' do
      it 'returns lists of Mailchimp' do
        # Arrange
        allow(mailchimp_instance).to receive(:lists).and_return(['Test 1', 'Test 2'])
        # Act
        lists = mailchimp_instance.lists
        # Assert
        expect(lists).to be_an(Array)
        expect(lists).not_to be_empty
        expect(lists.first).to include('Test 1')
      end
    end

    context 'when API call fails' do
      it 'raises a custom error with appropriate message w.r.t status' do
        # Arrange
        allow(mailchimp_instance).to receive(:lists).and_raise(StandardError.new("{:message=>\"ESP Adapter: Resource not found. Please verify the provided list ID.\", :status=>404}"))
        # Act & Assert
        expect { mailchimp_instance.lists }.to raise_error(StandardError, /ESP Adapter: Resource not found/)
      end

      it 'raises a server custom error with appropriate message' do
        # Arrange
        allow(mailchimp_instance).to receive(:lists).and_raise(StandardError.new("{:message=>\"ESP Adapter: Internal Server Error.\", :status=>500}"))
        # Act & Assert
        expect { mailchimp_instance.lists }.to raise_error(StandardError, /ESP Adapter: Internal Server Error/)
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
          last_send_date: '2024-03-29'
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
        allow(mailchimp_instance).to receive(:list_metrics).with(list_id).and_raise(StandardError.new("{:message=>\"ESP Adapter: Resource not found. Please verify the provided list ID.\", :status=>404}"))
        # Act & Assert
        expect { mailchimp_instance.list_metrics(list_id) }.to raise_error(StandardError, /ESP Adapter: Resource not found/)
      end

      it 'raises a server error with appropriate message' do
        # Arrange
        allow(mailchimp_instance).to receive(:list_metrics).with(list_id).and_raise(StandardError.new("{:message=>\"ESP Adapter: Internal Server Error.\", :status=>500}"))
        # Act & Assert
        expect { mailchimp_instance.list_metrics(list_id) }.to raise_error(StandardError, /ESP Adapter: Internal Server Error/)
      end
    end
  end
end
