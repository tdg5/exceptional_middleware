require "test_helper"
require "test_helpers/test_middlewares"
require "exceptional_middleware/handler/middleware_handler"

module ExceptionalMiddleware::Handler
  class MiddlewareHandlerTest < ExceptionalMiddleware::TestCase
    Subject = MiddlewareHandler
    AlphaMiddleware = ExceptionalMiddleware::Test::Middleware::AlphaMiddleware
    BetaMiddleware = ExceptionalMiddleware::Test::Middleware::BetaMiddleware

    class TestIncluder
      self.singleton_class.send(:attr_reader, :handler)
      include Subject
    end

    class TestHandler
      def initialize(handler_proc)
        @handler_proc = handler_proc
      end

      def handle(remote_exception)
        @handler_proc.call(remote_exception)
      end
    end

    context Subject.name do
      subject { Subject }

      context "including class" do
        subject { TestIncluder }

        context "::middleware" do
          should "return a MiddlewareStack" do
            assert_kind_of ExceptionalMiddleware::MiddlewareStack, subject.middleware
          end
        end

        context "::handle" do
          setup do
            # Reset middleware!
            new_stack = ExceptionalMiddleware::MiddlewareStack.new
            subject.instance_variable_set(:@middleware, new_stack)
          end

          context "without middleware" do
            should "call the handler method with the remote exception" do
              remote_exception = :remote_exception
              (handle_method = mock).expects(:call).with(remote_exception)
              setup_handler(handle_method)
              subject.handle(remote_exception)
            end
          end

          context "with middleware" do
            should "wrap the handler in all middlewares" do
              call_order = sequence(:call_order)

              # Setup handler and middleware results
              handle_method = :handle_method
              setup_handler(handle_method)
              alpha_result = mock
              beta_result = :beta_result
              beta_arg = true

              # Middlewares will be called in reverse order
              BetaMiddleware.expects(:wrap).
                in_sequence(call_order).
                with(handle_method, beta_arg).
                returns(beta_result)
              AlphaMiddleware.expects(:wrap).
                in_sequence(call_order).
                with(beta_result).
                returns(alpha_result)

              # Should be called last!
              remote_exception = :remote_exception
              alpha_result.expects(:call).in_sequence(call_order).with(remote_exception)

              # Go!
              subject.middleware.use(AlphaMiddleware)
              subject.middleware.use(BetaMiddleware, beta_arg)
              subject.handle(remote_exception)
            end

            should "pass through all middleware before calling wrapped handler" do
              remote_exception = :remote_exception
              call_count = 0
              call_counter = lambda { call_count += 1 }
              subject.middleware.use(AlphaMiddleware, call_counter)
              subject.middleware.use(BetaMiddleware, true, call_counter)
              handle_method_called = false
              setup_handler(->(remote_ex) { handle_method_called = true })

              subject.handle(remote_exception)
              assert_equal 2, call_count
              assert_equal true, handle_method_called
            end

            should "allow middlewares not to invoke their successor" do
              remote_exception = :remote_exception
              call_count = 0
              call_counter = lambda { call_count += 1 }
              subject.middleware.use(AlphaMiddleware, call_counter)
              subject.middleware.use(BetaMiddleware, false, call_counter)
              (handle_method = mock).expects(:call).never
              setup_handler(handle_method)

              # Should still call both middlewares, but not the handle method
              subject.handle(remote_exception)
              assert_equal 2, call_count
            end
          end
        end
      end
    end

    def setup_handler(handle_method)
      (mock_handler = mock).
        expects(:method).
        with(:handle).
        returns(handle_method)
      subject.expects(:handler).returns(mock_handler)
    end
  end
end
