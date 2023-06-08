# frozen_string_literal: true

require_relative '../buffer'
require_relative '../chatter'
require_relative '../conf/vips'

module Tw
  module Handlers
    # Send a command when vips in the list type a chat command
    class Vip
      def initialize(vips, vip_word_list)
        @semaphore = Mutex.new
        @vips = vips
        @vip_word_list = vip_word_list
        @cooldown_seconds = 600
      end

      def on_cooldown?(hash, key)
        !hash[key].nil? && hash[key] + @cooldown_seconds > Time.now.to_i
      end

      def time_left(timestamp)
        (timestamp + @cooldown_seconds - Time.now.to_i)
      end

      def operation(message)
        proc do
          next nil unless @vips.include?(message[:user])

          next nil unless message[:body].start_with?('!sound')

          next false if on_cooldown?(@vips, message[:user])

          message_array = message[:body].split(' ')

          next nil unless message_array.size == 2

          next nil unless @vip_word_list.include?(message_array[1])

          next false if on_cooldown?(@vip_word_list, message_array[1])

          @semaphore.synchronize do
            @vips[message[:user]] = Time.now.to_i
            @vip_word_list[message_array[1]] = Time.now.to_i
          end

          true
        end
      end

      def callback(message, player, chatter)
        proc do |result|
          if result
            cmd = "#{self.class.name.split('::').last.downcase},#{message[:user]},#{message[:body].split(' ')[1]}"
            EM.defer(player.operation(cmd), player.callback, player.errback)
          elsif !result.nil?
            msg = "@#{message[:user]} "

            if on_cooldown?(@vips, message[:user])
              msg << "you are on cooldown for #{time_left(@vips[message[:user]])} seconds"
            else
              vip_word = message[:body].split(' ')[1]
              msg << "#{vip_word} is on cooldown for #{time_left(@vip_word_list[vip_word])} seconds"
            end

            EM.defer(chatter.operation(msg), chatter.callback, chatter.errback)
          end
        end
      end
    end
  end
end
