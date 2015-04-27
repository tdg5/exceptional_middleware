require "mad_libs/flake/simple_flake"

module MadLibs::Flake::RandomExponentialBackoffFlake
  class ResponseStrategy < MadLibs::Flake::ResponseStrategy
    def initialize(options = {})
      super
      @consecutive_failures = 0
      @time_excess = 0
    end

    def on_decide(is_success)
      if is_success
        @consecutive_failures = 0
        @next_call_time = nil
      else
        @consecutive_failures += 1
        term = 1 << @consecutive_failures
        wait_time = (term + rand(term / 10 + 250)) / 1000.0
        @next_call_time = Time.now.to_f + wait_time
      end
    end

    def decide
      call_time = Time.now.to_f
      if @next_call_time && call_time < @next_call_time
        @call_stats[:rejected] += 1
        return false
      elsif @next_call_time
        @time_excess += call_time - @next_call_time
      end

      super
    end

    def time_stats
      t_stats = super
      t_stats[:optimal] = t_stats[:total] - @time_excess
      t_stats
    end
  end

  def self.new(frequency = 4)
    response_strategy = ResponseStrategy.new(:frequency => frequency)
    MadLibs::Flake::SimpleFlake.new(response_strategy)
  end
end
