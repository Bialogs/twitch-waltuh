# frozen_string_literal: true

module Tw
  class Irc
    attr_accessor :channel, :ws

    def initialize(ws, channel)
      @channel = channel
      @ws = ws
    end

    def join(oauth_string, twitch_user)
      ws.send("PASS oauth:#{oauth_string}")
      ws.send("NICK #{twitch_user}")
      ws.send("JOIN ##{@channel}")
    end

    def parse_message(message)
      matches = message.match(/^:(.*)!(.*)@(.*) PRIVMSG (.*) :(.*)$/)
      return nil if matches.nil?

      {
        user: matches[1],
        channel: matches[4],
        body: matches[5]
      }
    end

    def handle_ping(message)
      # is this message a ping from twitch server?
      if message.chomp!.eql?('PING :tmi.twitch.tv')
        pong
        true
      end
      false
    end

    def pong
      ws.send('PONG :tmi.twitch.tv')
    end

    def send_message(message)
      ws.send("PRIVMSG ##{@channel} :#{message}")
    end
  end
end
