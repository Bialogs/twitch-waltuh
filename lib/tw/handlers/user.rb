# frozen_string_literal: true

module Tw
  module Handlers
    class User
      def initialize(user_list)
        @user_list = user_list
        @cooldown_seconds = 60
        @last_solved_at = nil
      end

      def on_cooldown?
        !@last_solved_at.nil? && @last_solved_at + @cooldown_seconds > Time.now.to_i
      end

      def operation(message)
        proc do
          next false if on_cooldown?

          next false unless @user_list.include?(message[:user])

          @last_solved_at = Time.now.to_i
          next true
        end
      end

      def callback(player)
        proc do |result|
          if result
            cmd = self.class.name.split('::').last.downcase.to_s
            EM.defer(player.operation(cmd), player.callback, player.errback)
          end
        end
      end
    end
  end
end
