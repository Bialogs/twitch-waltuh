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
require_relative 'tw/conf/vips'

require_relative 'tw/media/remote_player'

module Tw
  def self.start(randomizer)
    randomizer.new_order
    Buffer.new(randomizer.order.size)
  end

  def self.on_cooldown?(ts)
    !ts.nil? && ts + 90 > Time.now.to_i
  end

  player = Media::RemotePlayer.new(conf.media_server)

  EM.run do
    ws = Faye::WebSocket::Client.new(conf.wss_server)
    irc = Irc.new(ws, conf.twitch_channel)

    word_order_buffer = self.start(randomizer)

    ws.on :open do |_event|
      irc.join(conf.oauth_string, conf.twitch_user)
    end

    ws.on :message do |event|
      p [:message, event.data]

      next if irc.handle_ping(event.data)
      next if self.on_cooldown?(last_solved_at)

      message = irc.parse_message(event.data)

      unless message.nil?
        message[:body].split(' ').each do |word|
          # When autocompleting with 7tv, BTTV, FFZ, this junk unicode character is sent.
          next if word == '\u{E0000}'

          # To speed up processing
          unless Conf::WORDS_SET.include?(word)
            word_order_buffer.reset
            next
          end

          word_order_buffer.insert(word)

          if word_order_buffer.values == randomizer.order
            last_solved_at = Time.now.to_i
            word_order_buffer = self.start(randomizer)
            EM.defer(player.operation(message[:user]), player.callback, player.errback)
            break
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
