require "exceptional_middleware/middleware/intervalic_retry_middleware"
require "exceptional_middleware/middleware/intervalic_retry_middleware/exponential_intervalometer"

module ExceptionalMiddleware::Middleware::IntervalicRetryMiddleware
  module TruncatedExponentialIntervalometer
    def self.included(includer)
      includer.extend(ClassMethods)
    end

    module ClassMethods
      def exponential_term(n)
        1 << n
      end

      def interval(remote_exception)
        retry_count = remote_exception.context[:retry_count] || 0
        term = exponential_term(retry_count)
        result = (term + rand(term / 10 + 250)) / 1000.0
        result < max_interval ? result : max_interval
      end

      def max_interval
        1 << 18
      end
    end
  end
end
