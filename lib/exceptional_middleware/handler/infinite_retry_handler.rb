module ExceptionalMiddleware::Handler
  module InfiniteRetryHandler
    def self.included(includer)
      includer.extend(ClassMethods)
    end

    module ClassMethods
      def handle(remote_exception)
        remote_exception.retry
        nil
      end
    end

    extend(ClassMethods)
  end
end
