# frozen_string_literal: true

require_relative '../buffer'

module Tw
  module Handlers
    # Send a command when the chat contains 1/5, 2/5, ... 5/5 within a time period
    class VoteKick
      def initialize
        @semaphore = Mutex.new
        @voters = Set[]
        @first = nil
        @start_time = nil
        @vote_seconds = 90
        @cooldown_seconds = 1800
        @last_triggered = nil
        @vote_words = Set['1/5', '2/5', '3/5', '4/5', '5/5']
        # @vote_words = Set['1', '2', '3', '4', '5']
        @seen = Set[]
      end

      def on_cooldown?
        !@last_solved_at.nil? && @last_triggered + @cooldown_seconds > Time.now.to_i
      end

      def reset
        @start_time = nil
        @seen = Set[]
        @voters = Set[]
      end

      def operation(message)
        proc do
          next false if on_cooldown?

          @semaphore.synchronize do
            if !@start_time.nil? && @start_time + @vote_seconds < Time.now.to_i
              reset
              p 'Vote timed out'
            end
          end

          next false if @voters.include?(message[:user])

          words = message[:body].split(' ').to_set

          in_common = @vote_words & words
          next false unless in_common.size == 1

          in_common = in_common.first
          success = false

          @semaphore.synchronize do
            @seen.add(in_common)
            @voters.add(message[:user])

            if @start_time.nil? && @seen.size == 1
              @start_time = Time.now.to_i
              @first = message[:user]
            end

            p @seen
            if @seen == @vote_words && @voters.size == @vote_words.size
              success = true
              reset
            end
          end

          next success
        end
      end

      def callback(player)
        proc do |result|
          if result
            cmd = "#{self.class.name.split('::').last.downcase},#{@first}"
            EM.defer(player.operation(cmd), player.callback, player.errback) if result
          end
        end
      end
    end
  end
end
