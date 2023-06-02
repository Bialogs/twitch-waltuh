# frozen_string_literal: true

require 'faye/websocket'

module Tw
  module Media
    # This player class is designed to work with an Eventmachine Defer operation
    # and communicate with a WSS running at TW_MEDIA_SERVER to play media
    # (i.e. in a browser)
    class RemotePlayer
      def initialize(wss)
        @wss = wss
      end

      def operation(trigger)
        proc do
            wsc = Faye::WebSocket::Client.new(@wss)
            wsc.send(trigger.to_s)
        end
      end

      def callback
        proc do |result|
          if result
            p 'message sent'
          else
            p 'message failed to send and connection closed'
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
end
