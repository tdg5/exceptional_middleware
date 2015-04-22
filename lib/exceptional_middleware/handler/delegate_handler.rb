module ExceptionalMiddleware::Handler
  # A mixin that adds Matcher behaviors that simply wrap another object. Calls
  # to determine equality are delegated to the wrapped object.
  module DelegateHandler
    # Adds behaviors to the Class or Module that includes this module.
    #
    # @param includer [Class, Module] The Class or Module to include
    #   DelegateMatcher behavior in.
    # @return [void]
    def self.included(includer)
      includer.extend(ClassMethods)
      includer.singleton_class.instance_eval do
        attr_accessor :handler_delegate
      end
    end

    # Factory function for creating modules with DelegateMatcher behaviors.
    # Creates a new module with DelegateMatcher behaviors where the given block
    # will be used to evaluate matches. Similar to Module::new, if a block is
    # given, the block will be evaluated on the generated module using
    # module_eval after the DelegateMatcher behaviors have been added to the
    # module.
    #
    # @param handler [Object] The object that should be delegated to when ::===
    #   is invoked on the generated module.
    # @return [Module] Returns a new Module that includes Matcher behaviors.
    def self.new(handler = nil, &init_block)
      # Closures, baby!
      delegate_handler = self
      Module.new do
        include delegate_handler
        @handler_delegate = handler
        module_eval(&init_block) if init_block
      end
    end

    module ClassMethods
      # Used by Ruby's rescue keyword to evaluate if an exception instance can be
      # caught by this Class or Module. Delegates to {#handler_delegate}.
      #
      # @param remote_exception [RemotelyExceptional::RemoteException] The
      #   remote exception instance that should be handled.
      # @return [void]
      def handle(remote_exception)
        handler_delegate.handle(remote_exception)
        nil
      end
    end
  end
end

