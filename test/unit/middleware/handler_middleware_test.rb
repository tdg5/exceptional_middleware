require "test_helper"
require "exceptional_middleware/middleware/handler_middleware"

module ExceptionalMiddleware::Middleware
  class HandlerMiddlewareTest < ExceptionalMiddleware::TestCase
    Subject = HandlerMiddleware

    context Subject.name do
      subject { Subject }

      context "::wrap" do
        should "return a proc" do
          assert_kind_of Proc, subject.wrap(mock, mock)
        end

        should "handle the remote exception with the handler" do
          (remote_exception = mock).expects(:action?).returns(true)
          (successor = mock).expects(:call).never

          (handler = mock).expects(:handle).with(remote_exception)
          wrapper = subject.wrap(successor, handler)
          wrapper.call(remote_exception)
        end

        should "execute the successor if the handler didn't cause an action" do
          (remote_exception = mock).expects(:action?).returns(false)
          (successor = mock).expects(:call).with(remote_exception)

          (handler = mock).expects(:handle).with(remote_exception)
          wrapper = subject.wrap(successor, handler)
          wrapper.call(remote_exception)
        end
      end
    end
  end
end
