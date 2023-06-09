# frozen_string_literal: true

module Tw
  module Handlers
    # Send a command when a random dice roll lands on 6
    class Six
      def initialize
        @bot = 'nightbot'
        @text = 'rolled 6'
      end

      def operation(message)
        proc do
          next false unless message[:user] == @bot

          next false unless message[:body].include?(@text)

          p '6 rolled'

          next true
        end
      end

      def callback(player)
        proc do |result|
          if result
            cmd = "#{self.class.name.split('::').last.downcase}"
            EM.defer(player.operation(cmd), player.callback, player.errback)
          end
        end
      end
    end
  end
end
