# frozen_string_literal: true

module Tw
  # IRC over Websockets communication with the Twitch server
  class Irc
    attr_accessor :channel, :wsc

    def initialize(wsc, channel)
      @channel = channel
      @wsc = wsc
    end

    def join(oauth_string, twitch_user)
      @wsc.send("PASS oauth:#{oauth_string}")
      @wsc.send("NICK #{twitch_user}")
      @wsc.send("JOIN ##{@channel}")
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
      @wsc.send('PONG :tmi.twitch.tv')
    end

    def send_message(message)
      @wsc.send("PRIVMSG ##{@channel} :#{message}")
    end
  end
end
