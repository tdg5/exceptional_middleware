require "test_helper"
require "test_helpers/test_remote_exceptions"
require "exceptional_middleware/middleware/intervalic_retry_middleware"

module ExceptionalMiddleware::Middleware
  class IntervalicRetryMiddlewareTest < ExceptionalMiddleware::TestCase
    Subject = IntervalicRetryMiddleware
    RemoteException = ExceptionalMiddleware::Test::BasicRemoteException

    class TestIncluder
      include Subject
    end

    module IntervalometerImplementer
      def intervalometer
        raise RuntimeError
      end
    end

    context Subject.name do
      context "including module" do
        subject { TestIncluder }

        context "::intervalometer" do
          should "defer to super if a super method exists" do
            super_mod = Module.new.instance_eval do
              extend IntervalometerImplementer
              include Subject
            end
            # Should raise RuntimeError if super was called correctly
            exception = assert_raises(RuntimeError) { super_mod.intervalometer }
            # Should include intervalic_retry_middleware in the stack if it's
            # really been invoked via super
            assert_match(/intervalic_retry_middleware/, exception.backtrace[1])
          end

          should "raise NotImplementedError if super not available" do
            assert_raises(NotImplementedError) do
              subject.intervalometer
            end
          end
        end

        context "::wrap" do
          setup do
            @remote_exception = RemoteException.new
            @intervalometer = mock
            subject.stubs(:intervalometer).returns(@intervalometer)
          end

          should "return a proc" do
            assert_kind_of Proc, subject.wrap(stubs(:call => true))
          end

          context "the intervalometer does not yield an interval" do
            should "raise the remote exception" do
              @intervalometer.expects(:interval).with(@remote_exception)
              @remote_exception.expects(:raise)
              wrapper = subject.wrap(nil)
              wrapper.call(@remote_exception)
            end

            should "not sleep or retry the remote exception" do
              @intervalometer.expects(:interval).with(@remote_exception)
              subject.expects(:sleep).never
              (mck = mock).expects(:call).never
              wrapper = subject.wrap(mck)
              wrapper.call(@remote_exception)
            end
          end

          should "call the wrapped method after the sleep interval" do
            interval = 5
            @intervalometer.expects(:interval).with(@remote_exception)
              .returns(interval)

            subject.expects(:sleep).with(interval)
            (mck = mock).expects(:call).with(@remote_exception)
            wrapper = subject.wrap(mck)
            wrapper.call(@remote_exception)
          end
        end
      end
    end
  end
end
