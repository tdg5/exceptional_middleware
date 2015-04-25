# Middleware providing exponential backoff functionality.
module ExceptionalMiddleware::Middleware::IntervalicRetryMiddleware
  def self.included(includer)
    includer.extend(ClassMethods)
  end

  # Behaviors that the including Module or Class should be extended with.
  module ClassMethods
    # Wraps the given successor method in a Proc that adds exponential backoff
    # logic such that the successor is invoked at larger and larger intervals as
    # the number of retries increases. If no interval is returned, the remote
    # exception is raised and further execution of the middleware stack is short
    # circuited.
    #
    # @param successor [#call] The successor Object that should be invoked
    #   with exponential backoff.
    # @param intervalometer [#interval] The intervalometer Object that should be
    #   used to determine the interval with which the exception should be handled.
    # @return [Proc] A new Proc with exponenital backoff behavior.
    def wrap(successor, intervalometer)
      lambda do |remote_exception|
        interval = intervalometer.interval(remote_exception)
        return remote_exception.raise unless interval

        sleep(interval)
        successor.call(remote_exception)
      end
    end
  end
end
