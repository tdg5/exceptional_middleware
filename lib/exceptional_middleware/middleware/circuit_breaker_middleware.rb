module ExceptionalMiddleware::Middleware::CircuitBreaker
  def self.included(includer)
    includer.extend(ClassMethods)
  end

  module ClassMethods
    def should_suppress?(remote_exception)
      raise NotImplementedError, "#{__method__} must be implemented by including class!"
    end

    def wrap(successor)
      lambda do |remote_exception|
        unless should_suppress?(remote_exception)
          successor.call(remote_exception)
        end
        nil
      end
    end
  end
end
