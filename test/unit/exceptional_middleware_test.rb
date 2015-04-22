require "test_helper"

module ExceptionalMiddleware
  class ExceptionalMiddlewareTest < TestCase
    Subject = ExceptionalMiddleware

    [
      Subject,
      Subject::Middleware,
    ].each do |mod|
      context mod.name do
        subject { mod }

        should "be defined" do
          assert_kind_of Module, subject
        end
      end
    end
  end
end
