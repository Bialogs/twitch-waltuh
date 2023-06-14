# frozen_string_literal: true

module Tw
  # Words Config
  module Conf
    emote_list = File.read(File.join(File.expand_path(__dir__), 'emotes.txt')).split("\n")
    EMOTE_LIST = emote_list
    EMOTE_SET = emote_list.to_set
  end
end
