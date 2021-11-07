# frozen_string_literal: true

require 'singleton'

module StringHelpers
  class AddSuffixSingleton
    include Singleton

    def initialize
      @value = 0
    end

    def increment_and_get
      @value += 1
      @value
    end
  end

  def add_discriminator
    "#{self}##{AddSuffixSingleton.instance.increment_and_get}"
  end
end

class String
  include StringHelpers
end
