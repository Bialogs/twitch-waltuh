# frozen_string_literal: true

module Tw
  # Vip and Vip Words Config
  module Conf
    vip_list = File.read(File.join(File.expand_path(__dir__), 'vips.txt')).split("\n")
    vip_word_list = File.read(File.join(File.expand_path(__dir__), 'vip_words.txt')).split("\n")
    VIPS_HASH = {}
    vip_list.each { |vip| VIPS_HASH[vip] = nil }
    VIP_WORD_LIST_HASH = {}
    vip_word_list.each { |vwl| VIP_WORD_LIST_HASH[vwl] = nil }
  end
end
