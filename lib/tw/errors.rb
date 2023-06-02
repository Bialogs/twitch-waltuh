# frozen_string_literal: true

module Tw
  class Error < StandardError; end

  class ConfigurationError < Error
    def initialize(message: 'No configuration was provided for', config: 'an option')
      @config = config
      super("#{message} #{@config}")
    end
  end
end
