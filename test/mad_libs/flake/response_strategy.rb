module MadLibs::Flake
  class ResponseStrategy
    DEFAULT_OPTIONS = { :frequency => 10 }.freeze

    def initialize(options = {})
      opts = default_options.merge!(options)
      @frequency = opts[:frequency]
      @call_stats = Hash.new(0)
    end

    def call
      call_time = Time.now.to_f
      @start_time ||= call_time
      @last_call_time = call_time
      @call_stats[:total] += 1
      decide
    end

    def call_stats
      @call_stats.dup
    end

    def decide
      decision = rand(@frequency) == 0
      @call_stats[decision ? :success : :failure] += 1
      @call_stats[:optimal] += 1
      on_decide(decision) if respond_to?(:on_decide)
      decision
    end

    def default_options
      self.class.const_get(:DEFAULT_OPTIONS).dup
    end

    def stats
      {
        :calls => call_stats,
        :time => time_stats,
      }
    end

    def time_stats
      total = @last_call_time ? @last_call_time - @start_time : 0
      {
        :optimal => total,
        :total => total,
      }
    end
  end
end
