# frozen_string_literal: true

module Tw
  # Selected users
  module Conf
    USERS_LIST = File.read(File.join(File.expand_path(__dir__), 'users.txt')).split("\n")
    USERS_SET = USERS_LIST.to_set
  end
end
