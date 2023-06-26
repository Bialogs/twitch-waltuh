# frozen_string_literal: true

module Tw
  module Handlers
    # Send a command when the random word (emote) is typed in chat
    # Changes the word after a correct trigger
    class RandomEmote
      def initialize(emotes_set, emotes_array)
        @semaphore = Mutex.new
        @last_solved_at = nil
        @emotes_set = emotes_set
        @emotes_array = emotes_array
        @last_emote = nil
        @cooldown_seconds = 300
        @selected_emote = @emotes_array.sample
        p "Random emote is #{@selected_emote}"
      end

      def on_cooldown?
        !@last_solved_at.nil? && @last_solved_at + @cooldown_seconds > Time.now.to_i
      end

      def operation(message)
        proc do
          next false if on_cooldown?

          words = message[:body].split(' ').to_set

          next false unless words.include?(@selected_emote)

          @semaphore.synchronize do
            @last_solved_at = Time.now.to_i
            @last_emote = @selected_emote
            @selected_emote = @emotes_array.sample
            p "Random emote is #{@selected_emote}"
          end

          next true
        end
      end

      def callback(message, player)
        proc do |result|
          if result
            p 'Random emote found'
            cmd = "#{self.class.name.split('::').last.downcase},#{message[:user]},#{@last_emote}"
            EM.defer(player.operation(cmd), player.callback, player.errback)
          end
        end
      end
    end
  end
end
