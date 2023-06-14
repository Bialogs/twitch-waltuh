# frozen_string_literal: true

require 'eventmachine'
require 'faye/websocket'

require_relative 'tw/version'
require_relative 'tw/errors'
require_relative 'tw/configuration'
require_relative 'tw/irc'
require_relative 'tw/remote_player'
require_relative 'tw/chatter'

require_relative 'tw/handlers/randomizer'
require_relative 'tw/handlers/vip'
require_relative 'tw/handlers/combo'
require_relative 'tw/handlers/vote_kick'
require_relative 'tw/handlers/sunnies'
require_relative 'tw/handlers/user'

require_relative 'tw/conf/random_words'
require_relative 'tw/conf/vips'
require_relative 'tw/conf/sunnies'
require_relative 'tw/conf/users'

# Main program module containing setup, event loop initialization, and handler
# registration
module Tw
  conf = Configuration.new
  player = RemotePlayer.new(conf.media_server)

  randomizer = Handlers::Randomizer.new(Conf::RANDOM_WORDS)
  vip = Handlers::Vip.new(Conf::VIPS_HASH, Conf::VIP_WORD_LIST_HASH)
  combo = Handlers::Combo.new
  vote_kick = Handlers::VoteKick.new
  sunnies = Handlers::Sunnies.new(Conf::SUNNIES_WORDS_SET)
  user = Handlers::User.new(Conf::USERS_SET)

  EM.run do
    ws = Faye::WebSocket::Client.new(conf.wss_server)
    irc = Irc.new(ws, conf.twitch_channel)
    chatter = Chatter.new(irc)

    ws.on :open do |_event|
      irc.join(conf.oauth_string, conf.twitch_user)
      EM.add_periodic_timer(60) do
        next if randomizer.hint_on_cooldown?

        irc.send_message(randomizer.hint)
      end

      # 5 hours 45 minutes
      EM.add_periodic_timer(19620) do
        player.operation('user').call
      end
    end

    ws.on :message do |event|
      p [:message, event.data]

      next if irc.handle_ping(event.data)

      message = irc.parse_message(event.data)

      unless message.nil?
        EM.defer(vip.operation(message), vip.callback(message, player, chatter))
        EM.defer(combo.operation(message), combo.callback(player))
        EM.defer(randomizer.operation(message), randomizer.callback(message, player))
        EM.defer(vote_kick.operation(message), vote_kick.callback(player))
        EM.defer(sunnies.operation(message), sunnies.callback(player))
        EM.defer(user.operation(message), user.callback(player))
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
