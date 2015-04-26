require "exceptional_middleware/middleware/intervalic_retry_middleware"

module ExceptionalMiddleware::Middleware::IntervalicRetryMiddleware
  class ConstantIntervalometer
    def initialize(interval)
      @interval = interval
    end

    def interval(*)
      @interval
    end
  end
end
