# Adds circuit breaker like behavior to the middleware stack allowing for
# additional exception handling to be short-circuited. In situations where a lot
# of exceptions are occuring this type of behavior can be useful to prevent
# futile retries.
module ExceptionalMiddleware::Middleware::CircuitBreakerMiddleware
  # Wraps the given successor method in a Proc that adds circuit breaking
  # logic such that the successor is invoked when the {#halt?} method returns
  # false and is not invoked when the {#halt?} method returns true.
  #
  # @param successor [#call] The successor Object that should be invoked
  #   unless told to halt.
  # @param circuit_breaker [#halt?] The circuit breaker Object that should be
  #   invoked to decide to halt or proceed.
  # @return [Proc] A new Proc with circuit breaking behavior.
  def self.wrap(successor, circuit_breaker)
    lambda do |remote_exception|
      return if circuit_breaker.halt?(remote_exception)
      successor.call(remote_exception)
      nil
    end
  end
end
