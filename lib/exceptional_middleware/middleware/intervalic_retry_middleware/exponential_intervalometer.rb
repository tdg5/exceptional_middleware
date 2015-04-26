require "exceptional_middleware/middleware/intervalic_retry_middleware"

module ExceptionalMiddleware::Middleware::IntervalicRetryMiddleware
  module ExponentialIntervalometer
    def self.included(includer)
      includer.extend(ClassMethods)
    end

    module ClassMethods
      def exponential_term(n)
        1 << n
      end

      def interval(remote_exception)
        retry_count = remote_exception.context[:retry_count] ||= 0
        term = exponential_term(retry_count)
        (term + rand(term / 10 + 250)) / 1000.0
      end
    end
  end
end
