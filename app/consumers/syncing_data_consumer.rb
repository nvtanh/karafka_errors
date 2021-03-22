class SyncingDataConsumer < ApplicationConsumer
  include Karafka::Consumers::Callbacks
  after_fetch :process_message

  def consume
    Karafka.logger.warn('==== Consume ====')
  end

  private

  def process_message
    Karafka.logger.warn('==== Process ====')
  end
end
