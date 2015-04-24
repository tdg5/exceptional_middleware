module ExceptionalMiddleware
  module HandleCallbacks
    def self.included(includer)
    end

    class << self
      def handle(remote_exception)
        before_handle(remote_exception) if respond_to?(:before_handle)
        if respond_to?(:around_handle)
          around_handle(remote_exception) { handler.handle(remote_exception) }
        else
          handler.handle(remote_exception)
        end
        after_handle(remote_exception) if respond_to?(:after_handle)
      end
    end
  end
end
