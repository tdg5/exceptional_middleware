module ExceptionalMiddleware::Test
  module Middleware
    module AlphaMiddleware
      def self.wrap(successor, hook = nil)
        lambda do |remote_exception|
          hook.call if hook
          successor.call(remote_exception)
        end
      end
    end

    module BetaMiddleware
      def self.wrap(successor, call_through = true, hook = nil)
        lambda do |remote_exception|
          hook.call if hook
          successor.call(remote_exception) if call_through
        end
      end
    end
  end
end
