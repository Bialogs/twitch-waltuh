# frozen_string_literal: true

require_relative '../buffer'

module Tw
  module Handlers
    # Send a command when 25 B) emotes are sent in a row.
    class Sunnies
      def initialize(words)
        @semaphore = Mutex.new
        @last_solved_at = nil
        @count = 0
        @max = 25
        @last_solved_at = nil
        @cooldown_seconds = 90
        @sunnies_words = words
      end

      def on_cooldown?
        !@last_solved_at.nil? && @last_solved_at + @cooldown_seconds > Time.now.to_i
      end

      def operation(message)
        proc do
          next false if on_cooldown?

          words = message[:body].split(' ').to_set

          in_common = @sunnies_words & words
          if in_common.size == 0
            @semaphore.synchronize do
              @count = 0
              next false
            end
          else
            @semaphore.synchronize do
              @count += 1
              p "Count: #{@count}"
              if @count == @max
                @last_solved_at = Time.now.to_i
                next true
              end

              next false
            end
          end
        end
      end

      def callback(player)
        proc do |result|
          if result
            p 'Sunnies Activated'
            cmd = "#{self.class.name.split('::').last.downcase}"
            EM.defer(player.operation(cmd), player.callback, player.errback)
          end
        end
      end
    end
  end
end
