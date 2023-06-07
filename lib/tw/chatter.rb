# frozen_string_literal: true

require_relative './irc'

module Tw
  # EM.defer style class that sends messages via the IRC client
  class Chatter
    def initialize(irc)
      @irc = irc
    end

    def operation(message)
      proc do
        @irc.send_message(message)
      end
    end

    def callback
      proc do |result|
        if result
          p 'IRC message sent'
        else
          p 'IRC message failed to send'
        end
      end
    end

    def errback
      proc do |error|
        p error.to_s
      end
    end
  end
end
