# frozen_string_literal: true

module Tw
  # Sunnies words Config
  module Conf
    sunnies_word_list = File.read(File.join(File.expand_path(__dir__), 'sunnies_words.txt')).split("\n")
    SUNNIES_WORDS = sunnies_word_list
    SUNNIES_WORDS_SET = word_list.to_set
  end
end
