require "test_helpers/flakes"
require "exceptional_middleware/handler/middleware_handler"
require "exceptional_middleware/handler/infinite_retry_handler"
require "exceptional_middleware/matcher/delegate_matcher"
require "exceptional_middleware/middleware/circuit_breaker_middleware"
require "exceptional_middleware/middleware/handler_middleware"
require "exceptional_middleware/middleware/intervalic_retry_middleware"
require "exceptional_middleware/middleware/intervalic_retry_middleware/constant_intervalometer"
require "exceptional_middleware/middleware/intervalic_retry_middleware/truncated_exponential_intervalometer"

module ExceptionalMiddleware::Test
  module Strategy
    module SimpleRetryStrategy
      Handler = ExceptionalMiddleware::Handler::InfiniteRetryHandler
      Intervalometer = ExceptionalMiddleware::Middleware::
        IntervalicRetryMiddleware::ConstantIntervalometer.new(0.1)

      include ExceptionalMiddleware::Matcher::DelegateMatcher
      self.matcher_delegate = ExceptionalMiddleware::Test::Flakes::FlakeException

      include ExceptionalMiddleware::Handler::MiddlewareHandler
      middleware.use(ExceptionalMiddleware::Middleware::IntervalicRetryMiddleware, Intervalometer)
      middleware.use(ExceptionalMiddleware::Middleware::HandlerMiddleware, Handler)
    end

    module ExponentialRetryStrategy
      module Handler
        Handler = ExceptionalMiddleware::Handler::InfiniteRetryHandler

        def self.handle(remote_exception)
          remote_exception.context[:retry_count] ||= 0
          remote_exception.context[:retry_count] += 1
          Handler.handle(remote_exception)
        end
      end

      Intervalometer = Module.new do
        include ExceptionalMiddleware::Middleware::
          IntervalicRetryMiddleware::TruncatedExponentialIntervalometer

        def self.max_interval
          3
        end
      end

      include ExceptionalMiddleware::Matcher::DelegateMatcher
      self.matcher_delegate = ExceptionalMiddleware::Test::Flakes::FlakeException

      include ExceptionalMiddleware::Handler::MiddlewareHandler
      middleware.use(ExceptionalMiddleware::Middleware::IntervalicRetryMiddleware, Intervalometer)
      middleware.use(ExceptionalMiddleware::Middleware::HandlerMiddleware, Handler)
    end
  end
end
