module ExceptionalMiddleware::Middleware::CircuitBreaker
  def self.included(includer)
    includer.extend(ClassMethods)
  end

  module ClassMethods
    def halt?(remote_exception)
      raise NotImplementedError, "#{__method__} must be implemented by including class!"
    end

    def wrap(successor)
      lambda do |remote_exception|
        successor.call(remote_exception) unless halt?(remote_exception)
        nil
      end
    end
  end
end
