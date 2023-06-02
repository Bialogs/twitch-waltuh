# frozen_string_literal: true

module Tw
  module Conf
    word_list = File.read(File.join(File.expand_path(__dir__), 'words.txt')).split("\n")
    WORDS = word_list
  end
end
