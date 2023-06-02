# frozen_string_literal: true

module Tw
  class Randomizer
    attr_reader :order

    def initialize(emote_list)
      @emote_list = emote_list
      @max_combinations = emote_list.size
      @order = []
    end

    def new_order
      @order = @emote_list.shuffle.take(rand(@max_combinations) + 1)
      p @order
    end
  end
end
