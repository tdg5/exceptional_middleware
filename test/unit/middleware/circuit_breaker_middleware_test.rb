require "test_helper"
require "exceptional_middleware/middleware/circuit_breaker_middleware"

module ExceptionalMiddleware::Middleware
  class CircuitBreakerTest < ExceptionalMiddleware::TestCase
    Subject = CircuitBreaker

    module TestIncluder
      include Subject
    end

    context "including module" do
      subject { TestIncluder }

      context "::halt?" do
        should "raise NotImplementedError" do
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
