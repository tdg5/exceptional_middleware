require "test_helper"
require "exceptional_middleware/middleware/circuit_breaker_middleware"

module ExceptionalMiddleware::Middleware
  class CircuitBreakerTest < ExceptionalMiddleware::TestCase
    Subject = CircuitBreaker

    module TestHaltImplementer
      def self.included(includer)
        includer.extend(ClassMethods)
      end

      module ClassMethods
        def halt?(remote_exception)
          raise RuntimeError
        end
      end
    end

    module TestIncluder
      include Subject
    end

    context "including module" do
      subject { TestIncluder }

      context "::halt?" do
        should "defer to super if a super method exists" do
          # Create the module so we can reference it in the closure.
          super_mod = Module.new.instance_eval do
            include TestHaltImplementer
            include Subject
          end
          # Should raise RuntimeError if super was called correctly
          exception = assert_raises(RuntimeError) { super_mod.halt?(:foo) }
          # Should include circuit_breaker_middleware in the stack if it's
          # really been invoked via super
          assert_match(/circuit_breaker_middleware/, exception.backtrace[1])
        end

        should "raise NotImplementedError if super not available" do
          assert_raises(NotImplementedError) do
            subject.halt?(:foo)
          end
        end
      end

      context "::wrap" do
        should "return a proc" do
          assert_kind_of Proc, subject.wrap(stubs(:call => true))
        end

        should "call the wrapped method if the call isn't suppressed" do
          remote_exception = :remote_exception
          subject.expects(:halt?).returns(false)
          (mck = mock).expects(:call).with(remote_exception)
          thinger = subject.wrap(mck)
          thinger.call(remote_exception)
        end

        should "not call the wrapped method if the call is suppressed" do
          remote_exception = :remote_exception
          subject.expects(:halt?).returns(true)
          (mck = mock).expects(:call).never
          thinger = subject.wrap(mck)
          thinger.call(remote_exception)
        end
      end
    end
  end
end
