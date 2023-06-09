# frozen_string_literal: true

module Tw
  # First-in-first-out buffer with a fixed size
  class Buffer
    attr_reader :values, :size

    def initialize(size)
      @size = size
      @values = Array.new(size)
    end

    def insert(element)
      @values.shift
      @values.push(element)
    end

    def reset
      @values = Array.new(@size)
    end
  end
end
