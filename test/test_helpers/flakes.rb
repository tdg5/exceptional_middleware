require "test_helpers/flakes/response_strategy"

module ExceptionalMiddleware::Test
  module Flakes
    class FlakeException < RuntimeError; end

    class Flake
      def initialize(response_strategy, request_strategy)
        @request_strategy = request_strategy
        @response_strategy = response_strategy
      end

      def call
        raise FlakeException unless @response_strategy.call
      end

      def stats
        stat = @response_strategy.stats
        stat[:strategy] = {
          :request => @request_strategy.name,
          :response => @response_strategy.class.name,
        }
        stat
      end
    end

    module TryTryAgain
      ResponseStrategy = ExceptionalMiddleware::Test::Flakes::ResponseStrategy

      def self.new(request_strategy, frequency = 8)
        Flake.new(ResponseStrategy.new(:frequency => frequency), request_strategy)
      end
    end

    module ExponentialRetry
      class ResponseStrategy < ExceptionalMiddleware::Test::Flakes::ResponseStrategy
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
            puts "must wait #{wait_time}"
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

      def self.new(request_strategy, frequency = 8)
        Flake.new(ResponseStrategy.new(:frequency => frequency), request_strategy)
      end
    end
  end
end
