# frozen_string_literal: true

require_relative '../buffer'
require_relative '../conf/words'

module Tw
  module Handlers
    class Randomizer
      def initialize(emote_list)
        @semaphore = Mutex.new
        @last_solved_at = nil
        @last_hint_at = Time.now.to_i
        @emote_list = emote_list
        @max_combinations = emote_list.size
        @semaphore.synchronize do
          @order = []
          new_order
          @buffer = Buffer.new(@order.size)
        end
      end

      def new_order
        @order = []
        (rand(@max_combinations) + 1).times do
          @order << @emote_list[rand(@max_combinations)]
        end
        print 'New Randomizer order is: '
        p @order
      end

      def on_cooldown?
        !@last_solved_at.nil? && @last_solved_at + 90 > Time.now.to_i
      end

      def process_sync(word)
        @semaphore.synchronize do
          unless Conf::WORDS_SET.include?(word)
            @buffer.reset
            next false
          end

          @buffer.insert(word)

          next false unless @buffer.values == @order

          @last_solved_at = Time.now.to_i
          new_order
          @buffer = Buffer.new(@order.size)
          true
        end
      end

      def operation(message)
        proc do
          is_success = false
          next is_success if on_cooldown?

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
            EM.defer(player.operation("#{self.class.name.split('::').last.downcase},#{message[:user]}"), player.callback,
                     player.errback)
          end
        end
      end

      def hint_enabled?
        now = Time.now.to_i
        @last_solved_at + 1800 >= now && @last_hint_at + 1800 >= now
      end

      def hint
        @last_hint_at = Time.now.to_i
        @semaphore.synchronize {
          if @order.size >= 4
            "!waltuh HINT. Length: #{@order.size} Combination: #{@order.tally}"
          else
            "!waltuh HINT. Length: #{@order.size}"
          end
        }
      end
    end
  end
end
