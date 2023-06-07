# frozen_string_literal: true

require 'eventmachine'
require 'faye/websocket'

require_relative 'tw/version'
require_relative 'tw/errors'
require_relative 'tw/configuration'
require_relative 'tw/irc'
require_relative 'tw/remote_player'

require_relative 'tw/handlers/randomizer'
require_relative 'tw/handlers/vip'
require_relative 'tw/handlers/combo'

require_relative 'tw/conf/words'
require_relative 'tw/conf/vips'

# Main program module containing setup, event loop initialization, and handler
# registration
module Tw
  conf = Configuration.new

  randomizer = Handlers::Randomizer.new(Conf::WORDS)
  vip = Handlers::Vip.new(Conf::VIPS_SET, Conf::VIP_WORD_LIST_SET)
  combo = Handlers::Combo.new

  player = Media::RemotePlayer.new(conf.media_server)

  EM.run do
    ws = Faye::WebSocket::Client.new(conf.wss_server)
    irc = Irc.new(ws, conf.twitch_channel)

    ws.on :open do |_event|
      irc.join(conf.oauth_string, conf.twitch_user)
      EM.add_periodic_timer(60) do
        next unless randomizer.hint_enabled?

        irc.send_message(randomizer.hint)
      end
    end

    ws.on :message do |event|
      p [:message, event.data]

      next if irc.handle_ping(event.data)

      message = irc.parse_message(event.data)

      # Add player & frontend support for type
      unless message.nil?
        EM.defer(vip.operation(message), vip.callback(message, player))
        EM.defer(combo.operation(message), combo.callback(player))
        EM.defer(randomizer.operation(message), randomizer.callback(message, player))
      end
    end

    ws.on :close do |event|
      p [:close, event.code, event.reason]
      ws = nil
    end
  end
rescue Interrupt
  p 'Shutting down'
end
