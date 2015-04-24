module ExceptionalMiddleware::ManiacHandler
  extend ExceptionalMiddleware::HandlerMiddleware
  include ExceptionalMiddleware::Matcher::DelegateMatcher
  include ExceptionalMiddleware::Matcher::DelegateHandler

  handler_middleware.use(ExceptionalMiddleware::Middleware::ExponentialBackoff)
  handler_middleware.use(ExceptionalMiddleware::Middleware::CircuitBreaker)

  self.matcher_delegate ||= lambda do |exception|
    [ArgumentError, TypeError] === exception
  end

  self.handler_delegate ||= ExceptionalMiddleware::Handler::PrioritizedHandler.new([
    [SomeHandler, :priority => 25],
  ])
end
