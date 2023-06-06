# frozen_string_literal: true

require_relative '../buffer'
require_relative '../conf/vips'

module Tw
  module Handlers
    class Vip
      def initialize(vips, vip_word_list)
        @vips_hash = {}
        vips.each do { |vip| vips_hash[vip] = nil }
        @vip_word_list = vip_word_list
      end

      def on_cooldown(key)
        !@vips_hash[key].nil? && @vips_hash[key] + 600 > Time.now.to_i
      end

      def operation(message)
        proc do
          next false if on_cooldown?(message[:user])

          next false unless message[:body].start_with?('!sound')

          message_array = message[:body].split(' ')

          next false unless message_array.size == 2

          next false unless @vip_word_list.include?(message_array[1]) in

          true
        end
      end

      def callback(message, player)
        proc do |result|
          if result
            cmd = "#{self.class.name.split('::').last.downcase},#{message[:user]},#{message[:body].split(' ')[1]}"
            EM.defer(player.operation(cmd), player.callback, player.errback)
          end
        end
      end
    end
  end
end
