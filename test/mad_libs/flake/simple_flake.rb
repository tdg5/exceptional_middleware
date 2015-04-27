require "mad_libs/flake/response_strategy"

module MadLibs::Flake
  class SimpleFlake
    def initialize(response_strategy)
      @response_strategy = response_strategy
    end

    def call
      raise FlakeException unless @response_strategy.call
    end

    def stats
      stat = @response_strategy.stats
      stat[:strategy] = {
        :response => @response_strategy.class.name,
      }
      stat
    end
  end
end
