# frozen_string_literal: true

require 'eventmachine'
require 'faye/websocket'

require_relative 'tw/version'
require_relative 'tw/errors'
require_relative 'tw/configuration'
require_relative 'tw/irc'
require_relative 'tw/randomizer'
require_relative 'tw/buffer'
require_relative 'tw/conf/words'
require_relative 'tw/media/local_player'
require_relative 'tw/media/remote_player'

module Tw
  def self.start(randomizer)
    randomizer.new_order
    Buffer.new(randomizer.order.size)
  end

  def self.initialize_player
    return
  end

  conf = Configuration.new
  randomizer = Randomizer.new(Conf::WORDS)
  player = conf.mode == 'local' ? Media::LocalPlayer.new : Media::RemotePlayer.new(conf.media_server)

  EM.run do
    ws = Faye::WebSocket::Client.new(conf.wss_server)
    irc = Irc.new(ws, conf.twitch_channel)

    word_order_buffer = start(randomizer)

    ws.on :open do |_event|
      irc.join(conf.oauth_string, conf.twitch_user)
    end

    ws.on :message do |event|
      p [:message, event.data]
      next if irc.handle_ping(event.data)

      message = irc.parse_message(event.data)
      unless message.nil?
        message[:body].split(' ').each do |word|
          next if word == '\u{E0000}'
          word_order_buffer.insert(word)
          if word_order_buffer.values == randomizer.order
            EM.defer(player.operation(message[:user]), player.callback, player.errback)
            word_order_buffer = start(randomizer)
          end
        end
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
