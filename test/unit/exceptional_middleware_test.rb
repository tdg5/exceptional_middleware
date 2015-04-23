require "test_helper"

module ExceptionalMiddleware
  class ExceptionalMiddlewareTest < TestCase
    Subject = ExceptionalMiddleware

    [
      Subject,
      Subject::Handler,
      Subject::Matcher,
      Subject::Middleware,
      Subject::Strategy,
    ].each do |mod|
      context mod.name do
        subject { mod }

        should "be defined" do
          assert_kind_of Module, subject
        end
      end
    end

    context Subject.name do
      subject { Subject }
      should "have a version" do
        assert_match(/\d+\.\d+\.\d+/, Subject::VERSION)
      end
    end
  end
end
