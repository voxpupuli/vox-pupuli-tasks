class GithubEvent
  class Base
    attr_reader :payload

    ##
    # Receive the payload and start processing it

    def initialize(payload)
      @payload = payload
      process
    end
  end
end
