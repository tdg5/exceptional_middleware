require "test_helper"
require "exceptional_middleware/middleware/circuit_breaker_middleware"

module ExceptionalMiddleware::Middleware
  class CircuitBreakerMiddlewareTest < ExceptionalMiddleware::TestCase
    Subject = CircuitBreaker

    context Subject.name do
      subject { Subject }

      context "::wrap" do
        should "return a proc" do
          assert_kind_of Proc, subject.wrap(mock, mock)
        end

        should "call the wrapped method if the call isn't suppressed" do
          remote_exception = :remote_exception
          (breaker = mock).expects(:halt?).returns(false)
          (mck = mock).expects(:call).with(remote_exception)
          wrapper = subject.wrap(mck, breaker)
          wrapper.call(remote_exception)
        end

        should "not call the wrapped method if the call is suppressed" do
          remote_exception = :remote_exception
          (breaker = mock).expects(:halt?).returns(true)
          (mck = mock).expects(:call).never
          wrapper = subject.wrap(mck, breaker)
          wrapper.call(remote_exception)
        end
      end
    end
  end
end
