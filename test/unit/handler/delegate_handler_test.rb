require "test_helper"
require "exceptional_middleware/handler/delegate_handler"

module ExceptionalMiddleware::Handler
  class DelegateHandlerTest < ExceptionalMiddleware::TestCase
    Subject = ExceptionalMiddleware::Handler::DelegateHandler

    class TestIncluder
      include Subject
    end

    context Subject.name do
      subject { Subject }

      context "::new" do
        let(:generated_module) { subject.new }
        let(:handler) { mock }

        should "generate a new Module" do
          assert_kind_of Module, generated_module
          assert_equal true, generated_module.ancestors.include?(subject)
        end

        should "include DelegateHandler behavior in the generated module" do
          assert_equal true, generated_module.respond_to?(:handler_delegate)
          assert_equal true, generated_module.respond_to?(:handler_delegate=)
          assert_equal true, generated_module.respond_to?(:handle)
        end

        should "set the generated modules handler_delegate" do
          handler_module = subject.new(handler)
          assert_equal handler, handler_module.handler_delegate
        end

        should "yield the module to a given block after it has been set up" do
          includes_delegate_handler = has_handler_delegate_set = false
          closure_subject, closure_handler = subject, handler
          subject.new(handler) do
            includes_delegate_handler = ancestors.include?(closure_subject)
            has_handler_delegate_set = self.handler_delegate == closure_handler
          end
          assert_equal true, includes_delegate_handler
          assert_equal true, has_handler_delegate_set
        end
      end
    end

    context "class that includes #{Subject.name}" do
      subject { TestIncluder }

      setup do
        subject.instance_eval { self.handler_delegate = nil }
      end

      context "::handle" do
        let(:method_name) { :handle }

        should "be responded to" do
          assert_equal true, subject.respond_to?(method_name)
        end

        should "call handler_delegate#handle with all arguments" do
          args = [
            ex = ArgumentError.new,
          ]
          (faux_handler = mock).expects(:handle).with(*args)
          subject.expects(:handler_delegate).returns(faux_handler)
          subject.handle(ex)
        end
      end

      context "::handler_delegate" do
        let(:method_name) { :handler_delegate }

        should "be responded to" do
          assert_equal true, subject.respond_to?(method_name)
        end

        should "return nil if no handler_delegate has been set" do
          assert_nil subject.handler_delegate
        end

        should "return the handler_delegate, if set" do
          handler = :handler
          subject.handler_delegate = handler
          assert_equal handler, subject.handler_delegate
        end
      end

      context "::handler_delegate=" do
        let(:method_name) { :handler_delegate= }

        should "be responded to" do
          assert_equal true, subject.respond_to?(:handler_delegate=)
        end

        should "set the includer's ::handler_delegate" do
          handler = :handler
          subject.handler_delegate = handler
          assert_equal handler, subject.handler_delegate
        end
      end

      context "::new" do
        should "not be overriden" do
          instance = subject.new
          assert_kind_of subject, instance
          assert_kind_of Subject, instance
        end
      end
    end
  end
end
