# frozen_string_literal: true

class TravisEvent
  class Push < TravisEvent::Base
    def process
      ::TravisEvent.new(payload)
    end
  end
end
