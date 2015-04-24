require "test_helper"
require "exceptional_middleware/middleware/exponential_backoff_middleware"

module ExceptionalMiddleware::Middleware
  class ExponentialBackoffMiddlewareTest < ExceptionalMiddleware::TestCase
    Subject = ExceptionalMiddleware::Middleware::ExponentialBackoffMiddleware

    context Subject.name do
      context "" do
        should "" do
        end
      end
    end
  end
end
