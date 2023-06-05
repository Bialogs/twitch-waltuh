# frozen_string_literal: true

require_relative '../buffer'
require_relative '../conf/vips'

module Tw
  module Handlers
    class Vip
      def initialize(vips, vip_word_list)
        @vips = vips
        @vip_word_list = vip_word_list
      end
    end
  end
end
