require "test_helper"
require "test_helpers/test_middlewares"
require "exceptional_middleware/handler/infinite_retry_handler"

module ExceptionalMiddleware::Handler
  class InfiniteRetryHandlerTest < ExceptionalMiddleware::TestCase
    Subject = InfiniteRetryHandler

    class TestIncluder
      include Subject
    end

    retry_remote_exception = lambda do
      (remote_exception = mock).expects(:retry)
      subject.handle(remote_exception)
    end

    context Subject.name do
      subject { Subject }

      context "::handle" do
        should("retry the remote exception", &retry_remote_exception)
      end

      context "including class" do
        subject { TestIncluder }

        context "#handle" do
          should("retry the remote exception", &retry_remote_exception)
        end
      end
    end
  end
end
