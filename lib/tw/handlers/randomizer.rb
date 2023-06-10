# frozen_string_literal: true

require_relative '../buffer'
require_relative '../conf/words'

module Tw
  module Handlers
    # Send a command when the words are typed in chat in the correct order.
    # Changes the order after each correct trigger.
    class Randomizer
      def initialize(emote_list)
        @semaphore = Mutex.new
        @cooldown_seconds = 90
        @hint_cooldown_seconds = 1800
        @last_solved_at = nil
        @last_hint_at = nil
        @emote_list = emote_list
        @max_combinations = emote_list.size
        @semaphore.synchronize do
          new_order
        end
      end

      def new_order
        @last_solved_at = Time.now.to_i
        @last_hint_at = nil
        @order = []
        (rand(@max_combinations) + 1).times do
          @order << @emote_list[rand(@max_combinations)]
        end
        print 'New Randomizer order is: '
        p @order
        @buffer = Buffer.new(@order.size)
      end

      def on_cooldown?
        @last_solved_at + @cooldown_seconds > Time.now.to_i
      end

      def process_sync(word)
        @semaphore.synchronize do
          unless Conf::WORDS_SET.include?(word)
            @buffer.reset
            next false
          end

          @buffer.insert(word)

          next false unless @buffer.values == @order

          new_order
          next true
        end
      end

      def operation(message)
        proc do
          is_success = false
          next is_success if on_cooldown?

          next if message[:user] == 'nightbot'

          message[:body].split(' ').each do |word|
            # When autocompleting with 7tv, BTTV, FFZ, this junk unicode character is sent.
            next if word == '\u{E0000}'

            is_success = process_sync(word)
          end

          is_success
        end
      end

      def callback(message, player)
        proc do |result|
          if result
            cmd = "#{self.class.name.split('::').last.downcase},#{message[:user]}"
            EM.defer(player.operation(cmd), player.callback, player.errback)
          end
        end
      end

      def hint_on_cooldown?
        now = Time.now.to_i
        @semaphore.synchronize do
          # If there has not been a hint yet and the Randomizer was last solved more than x seconds ago and
          # the last hint was given more than x seconds ago
          next @last_solved_at + @hint_cooldown_seconds >= now if @last_hint_at.nil?

          next @last_hint_at + @hint_cooldown_seconds >= now
        end
      end

      def hint
        @last_hint_at = Time.now.to_i
        @semaphore.synchronize do
          if @order.size >= 4
            "!waltuh HINT. Length: #{@order.size} Combination: #{@order.tally}"
          else
            "!waltuh HINT. Length: #{@order.size}"
          end
        end
      end
    end
  end
end
