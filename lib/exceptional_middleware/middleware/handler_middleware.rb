# Middleware that attempts to handle remote exceptions with a provided handler.
module ExceptionalMiddleware::Middleware::HandlerMiddleware
  # Returns a Proc that wraps the given successor such that the given handler is
  # first used to attempt to handle the remote exception. If the given handler
  # provides an action to the remote exception, execution of the middleware
  # stack is discontinued. If the handler does not provide the remote exception
  # with an action, execution of the middleware stack continues.
  # to the given handler to handle the remote exception.
  #
  # @param successor [#call] The successor Object that should be called if the
  #   given handler is unable to handle the remote exception.
  # @param handler [#handle] The handler Object that should be used to handle
  #   the remote exception.
  # @return [Proc] A new Proc with handler behavior.
  def self.wrap(successor, handler)
    lambda do |remote_exception|
      handler.handle(remote_exception)
      successor.call(remote_exception) unless remote_exception.action?
      nil
    end
  end
end
