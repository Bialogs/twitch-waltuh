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
      @order = []
      (rand(@max_combinations) + 1).times do
        @order << @emote_list[rand(@max_combinations)]
      end
      print "New order is: "
      p @order
    end
  end
end
