# frozen_string_literal: true

require_relative '../buffer'

module Tw
  module Handlers
    # Send a command when the chat contains 1/5, 2/5 ... within a time period
    class VoteKick
      def initialize
        @semaphore = Mutex.new
        @count = Buffer.new(5)
        @voters = []
      end

      def operation(message)
        proc do
        end
      end

      def callback(message, player)
        proc do |result|
          EM.defer(player.operation(cmd), player.callback, player.errback) if result
        end
      end
    end
  end
end
