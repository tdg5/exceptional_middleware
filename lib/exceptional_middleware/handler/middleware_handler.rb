require "exceptional_middleware/middleware_stack"

module ExceptionalMiddleware::Handler
  module MiddlewareHandler
    def self.included(includer)
      includer.extend(ClassMethods)
    end

    module ClassMethods
      def middleware
        @middleware ||= ExceptionalMiddleware::MiddlewareStack.new
      end

      def handle(remote_exception)
        base_handler = handler.method(:handle)
        # Must reverse middlewares to create expected successor chain.
        middleware.reverse_each do |middleware, args|
          base_handler = middleware.wrap(base_handler, *args)
        end
        base_handler.call(remote_exception)
      end
    end
  end
end
