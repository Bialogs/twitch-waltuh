# frozen_string_literal: true

require_relative '../buffer'

module Tw
  module Handlers
    class Combo
      def initialize
        @semaphore = Mutex.new
        @comboers = Buffer.new(1)
        @last = nil
      end

      def operation(message)
        proc do
          words = message[:body].split(' ')

          if words.size > 2 || words[-1] == '\u{E0000}'
            @semaphore.synchronize do
              @last = nil
              @comboers.reset
              false
            end
          else
            @semaphore.synchronize do
              @last = words.pop
              @comboers.insert(message[:user])
              @comboers.values.count > 0 && @comboers.values.uniq.count == 1
            end
          end
        end
      end

      def callback(player)
        proc do |result|
          if result
            p 'Combo Activated'
            EM.defer(player.operation("#{self.class.name.split('::').last.downcase},#{@comboers.values.join(' ')},#{@last}"), player.callback,
                     player.errback)
          end
        end
      end
    end
  end
end
