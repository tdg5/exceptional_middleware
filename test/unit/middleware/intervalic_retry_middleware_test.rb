require "test_helper"
require "test_helpers/test_remote_exceptions"
require "exceptional_middleware/middleware/intervalic_retry_middleware"

module ExceptionalMiddleware::Middleware
  class IntervalicRetryMiddlewareTest < ExceptionalMiddleware::TestCase
    Subject = IntervalicRetryMiddleware
    RemoteException = ExceptionalMiddleware::Test::BasicRemoteException

    context Subject.name do
      subject { Subject }

      context "::wrap" do
        setup do
          @remote_exception = RemoteException.new
          @intervalometer = mock
        end

        should "return a proc" do
          assert_kind_of Proc, subject.wrap(stubs(:call => true), @intervalometer)
        end

        context "the intervalometer does not yield an interval" do
          should "raise the remote exception" do
            @intervalometer.expects(:interval).with(@remote_exception)
            @remote_exception.expects(:raise)
            wrapper = subject.wrap(nil, @intervalometer)
            wrapper.call(@remote_exception)
          end

          should "not sleep or retry the remote exception" do
            @intervalometer.expects(:interval).with(@remote_exception)
            subject.expects(:sleep).never
            (mck = mock).expects(:call).never
            wrapper = subject.wrap(mck, @intervalometer)
            wrapper.call(@remote_exception)
          end
        end

        should "call the wrapped method after the sleep interval" do
          interval = 5
          @intervalometer.expects(:interval).with(@remote_exception)
            .returns(interval)

          subject.expects(:sleep).with(interval)
          (mck = mock).expects(:call).with(@remote_exception)
          wrapper = subject.wrap(mck, @intervalometer)
          wrapper.call(@remote_exception)
        end
      end
    end
  end
end
