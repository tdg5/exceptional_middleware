# Adds circuit breaker like behavior to the middleware stack allowing for
# additional exception handling to be short-circuited. In situations where a lot
# of exceptions are occuring this type of behavior can be useful to prevent
# futile retries.
module ExceptionalMiddleware::Middleware::CircuitBreaker
  def self.included(includer)
    includer.extend(ClassMethods)
  end

  # Behaviors that the including Module or Class should be extended with.
  module ClassMethods
    # Indicates if the circuit breaker has been tripped and whether execution
    # should be halted or whether the successor should be invoked instead. Must
    # be implemeneted by including Class/Module.
    #
    # @param remote_exception [RemotelyExceptional::RemoteException] The remote
    #   exception that needs handling.
    # @raise [NotImplementedError] Raised if the incluing Class or Module does
    #   not implement its own halt? method.
    # @return [Boolean] A Boolean value indicating whether or not the successor
    #   should be invoked. When true, the successor method will not be invoked.
    #   When false, the successor will be invoked.
    def halt?(remote_exception)
      raise NotImplementedError, "#{__method__} must be implemented by including class!"
    end

    # Wraps the given successor method in a Proc that adds circuit breaking
    # logic such that the successor is invoked when the {#halt?} method returns
    # false and is not invoked when the {#halt?} method returns true.
    #
    # @param successor [#call] The successor Object that should be invoked
    #   unless told to halt.
    # @return [Proc] A new Proc with circuit breaking behavior.
    def wrap(successor)
      lambda do |remote_exception|
        successor.call(remote_exception) unless halt?(remote_exception)
        nil
      end
    end
  end
end
