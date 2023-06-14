# frozen_string_literal: true

module Tw
  # Random Words Config
  module Conf
    random_word_list = File.read(File.join(File.expand_path(__dir__), 'random_words.txt')).split("\n")
    RANDOM_WORDS = random_word_list
    RANDOM_WORDS_SET = random_word_list.to_set
  end
end
