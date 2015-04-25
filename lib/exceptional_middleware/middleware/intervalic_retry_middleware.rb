# Middleware providing exponential backoff functionality.
module ExceptionalMiddleware::Middleware::IntervalicRetryMiddleware
  def self.included(includer)
    includer.extend(ClassMethods)
  end

  # Behaviors that the including Module or Class should be extended with.
  module ClassMethods
    # Returns the intervalometer object that should be used to determine when
    # and how often the exception should be retried. The returned intervalometer
    # should provide an interval method that takes a remote exception as an
    # argument. This method should be implemeneted via super or by overriding
    # the method in the including Class/Module.
    #
    # @raise [NotImplementedError] Raised if the incluing Class or Module does
    #   not implement its own intervalometer method.
    # @return [Object] The object that should be used as an intervalometer.
    def intervalometer
      return super if defined?(super)
      raise NotImplementedError, "#{__method__} must be implemented by including class!"
    end

    # Wraps the given successor method in a Proc that adds exponential backoff
    # logic such that the successor is invoked at larger and larger intervals as
    # the number of retries increases.
    #
    # @param successor [#call] The successor Object that should be invoked
    #   with exponential backoff.
    # @return [Proc] A new Proc with exponenital backoff behavior.
    def wrap(successor)
      lambda do |remote_exception|
        interval = intervalometer.interval(remote_exception)
        return remote_exception.raise unless interval

        sleep(interval)
        successor.call(remote_exception)
      end
    end
  end
end
