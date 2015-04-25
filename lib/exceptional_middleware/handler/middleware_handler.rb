require "exceptional_middleware/middleware_stack"

# Blueprint for a Handler Class or Module that uses a middleware stack when
# handling remote exceptions. Each middleware has access to its successor and
# the remote exception allowing for a variety of behaviors to be handled via
# middleware.
module ExceptionalMiddleware::Handler::MiddlewareHandler
  NULL_HANDLE = lambda { |remote_exception| remote_exception.raise }.freeze

  def self.included(includer)
    includer.extend(ClassMethods)
  end

  # Behaviors that the including Module or Class should be extended with.
  module ClassMethods
    # Handles the given remote_exception by composing the middleware callstack
    # and passing the remote exception through the middleware stack. Standrad
    # interface method used by Handler objects.
    #
    # @param remote_exception [ExceptionalMiddleware::RemoteException] The
    #   remote exception that requires handling.
    # @return [void]
    def handle(remote_exception)
      stack = respond_to?(:handler) ? handler.method(:handle) : NULL_HANDLE
      # Must reverse middlewares to create expected successor chain.
      middleware.reverse_each do |middleware, args|
        stack = middleware.wrap(stack, *args)
      end
      stack.call(remote_exception)
      nil
    end

    # The middleware stack that the including Class or Module will use to
    # handle exceptions.
    #
    # @return [ExceptionalMiddleware::MiddlewareStack] The object's middleware
    #   stack.
    def middleware
      @middleware ||= ExceptionalMiddleware::MiddlewareStack.new
    end
  end
end
