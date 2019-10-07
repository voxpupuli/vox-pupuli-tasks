# frozen_string_literal: true

class TravisEvent
  class Base
    attr_reader :payload

    def initialize(payload)
      @payload = payload
      process
    end
  end
end
