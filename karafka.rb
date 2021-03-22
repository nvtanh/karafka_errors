ENV['KARAFKA_ENV'] ||= ENV['RAILS_ENV']
raise('KARAFKA_ENV is not set') unless ENV['KARAFKA_ENV']
require ::File.expand_path('../config/environment', __FILE__)

Rails.application.eager_load!

class KarafkaApp < Karafka::App
  setup do |config|
    config.kafka.seed_brokers = ['kafka://localhost:9092']
    config.client_id = 'test-karafka-errors'
    config.backend = :inline
    config.batch_fetching = false
    config.logger = Karafka::Instrumentation::Logger.new.tap { |l| l.level = ::Logger::DEBUG }
  end

  Karafka.monitor.subscribe(Karafka::Instrumentation::StdoutListener.new)

  consumer_groups.draw do
    consumer_group :default do
      topic :syncing_data do
        consumer SyncingDataConsumer
      end
    end
  end
end

KarafkaApp.boot!

WaterDrop.setup do |water_config|
  water_config.deliver = !Karafka.env.test? # Don't send messages in test environment
end
