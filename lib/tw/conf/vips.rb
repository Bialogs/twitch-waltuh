# frozen_string_literal: true

module Tw
  module Conf
    vip_list = File.read(File.join(File.expand_path(__dir__), 'vips.txt')).split("\n")
    vip_word_list = File.read(File.join(File.expand_path(__dir__), 'vip_words.txt')).split("\n")
    VIPS = vip_list
    VIPS_SET = vip_list.to_set
    VIP_WORD_LIST = vip_word_list
    VIP_WORD_LIST_SET = vip_word_list.to_set
  end
end
