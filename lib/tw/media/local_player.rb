# frozen_string_literal: true

module Tw
  module Media
    # This player class is designed to work with an Eventmachine Defer operation
    class LocalPlayer
      def initialize
        @media_file = File.join(File.expand_path(__dir__), 'waltuh.mp3')
      end

      def operation(trigger)
        proc do
          puts "Trigger: #{trigger}"
          fork { exec 'mpg123', '-q', @media_file }
        end
      end

      def callback
        proc do |result|
          p result.to_s
        end
      end

      def errback
        proc do |error|
          p error.to_s
        end
      end
    end
  end
end
