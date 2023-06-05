# frozen_string_literal: true

require_relative '../buffer'

module Tw
  module Handlers
    class Combo
      def initialize
        @semaphore = Mutex.new
        @comboers = Buffer.new(5)
        @last_word = nil
        @triggerers = nil
        @combo_word = nil
        @last_solved_at = nil
      end

      def on_cooldown?
        !@last_solved_at.nil? && @last_solved_at + 1800 > Time.now.to_i
      end

      def broken_combo
        @last_word = nil
        @comboers.reset
        false
      end

      def operation(message)
        proc do
          next false if on_cooldown?

          words = message[:body].split(' ')

          if words.size > 2 || words[-1] == '\u{E0000}'
            @semaphore.synchronize do
              broken_combo
            end
          else
            @semaphore.synchronize do
              if words[0] != @last_word && !@last_word.nil?
                broken_combo
              else
                @last_word = words.pop
                @comboers.insert(message[:user])
                if !@comboers.values.any?(nil) && @comboers.values.uniq.count == @comboers.size
                  @last_solved_at = Time.now.to_i
                  @triggerers = @comboers
                  @combo_word = @last_word
                  broken_combo
                  true
                else
                  false
                end
              end
            end
          end
        end
      end

      def callback(player)
        proc do |result|
          if result
            p 'Combo Activated'
            EM.defer(player.operation("#{self.class.name.split('::').last.downcase},#{@triggerers.values.join(' ')},#{@combo_word}"), player.callback,
                     player.errback)
          end
        end
      end
    end
  end
end
