module ExceptionalMiddleware::Middleware::ExponentialBackoffMiddleware
  def self.included(includer)
    includer.extend(ClassMethods)
  end

  module ClassMethods
    def handle(remote_exception)
      remote_exception.context[:retry_count] ||= 0
    end
  end
end
