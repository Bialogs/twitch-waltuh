# frozen_string_literal: true

module Tw
  class Buffer
    attr_reader :values

    def initialize(size)
      @values = Array.new(size)
    end

    def insert(element)
      @values.shift
      @values.push(element)
    end
  end
end
