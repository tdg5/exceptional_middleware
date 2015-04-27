require "mad_libs/flake"
require "exceptional_middleware/handler/middleware_handler"
require "exceptional_middleware/handler/infinite_retry_handler"
require "exceptional_middleware/matcher/delegate_matcher"
require "exceptional_middleware/middleware/handler_middleware"
require "exceptional_middleware/middleware/intervalic_retry_middleware"
require "exceptional_middleware/middleware/intervalic_retry_middleware/constant_intervalometer"

module ExceptionalMiddleware::Test
  module Strategy
    module SimpleRetryStrategy
      def self.new(retry_sleep = 0.1)
        intervalometer = ExceptionalMiddleware::Middleware::
          IntervalicRetryMiddleware::ConstantIntervalometer.new(retry_sleep)
        handler = ExceptionalMiddleware::Handler::InfiniteRetryHandler
        strategy = Module.new do
          include ExceptionalMiddleware::Matcher::DelegateMatcher
          include ExceptionalMiddleware::Handler::MiddlewareHandler
        end
        strategy.matcher_delegate = MadLibs::Flake::FlakeException
        strategy.middleware.use(ExceptionalMiddleware::Middleware::IntervalicRetryMiddleware, intervalometer)
        strategy.middleware.use(ExceptionalMiddleware::Middleware::HandlerMiddleware, handler)
        strategy
      end
    end
  end
end
