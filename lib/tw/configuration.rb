# frozen_string_literal: true

module Tw
  class Configuration
    attr_reader :oauth_string, :wss_server, :twitch_user, :twitch_channel, :media_server, :mode

    def self.raise_unless_present(env)
      ENV.fetch(env) { raise Tw::ConfigurationError.new(config: env) }
    end

    class << self
      attr_reader :database
    end

    def initialize(configure_twitch: true)
      return unless configure_twitch

      @oauth_string = Configuration.raise_unless_present('TW_OAUTH_STRING')
      @twitch_user = Configuration.raise_unless_present('TW_TWITCH_USER')
      @twitch_channel = Configuration.raise_unless_present('TW_TWITCH_CHANNEL')
      @wss_server = ENV.fetch('TW_WSS_SERVER', 'wss://irc-ws.chat.twitch.tv:443')
      @mode = ENV.fetch('TW_MODE', 'local')
      if @mode != 'local'
        @media_server = Configuration.raise_unless_present('TW_MEDIA_SERVER')
      else
        @media_server = nil
      end
    end
  end
end
