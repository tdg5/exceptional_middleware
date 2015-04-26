require "test_helper"
require "exceptional_middleware/middleware/intervalic_retry_middleware/constant_intervalometer"

module ExceptionalMiddleware::Middleware::IntervalicRetryMiddleware
  class ConstantIntervalometerTest < ExceptionalMiddleware::TestCase
    Subject = ConstantIntervalometer

    context Subject.name do
      subject { Subject }

      context "instance" do
        subject { Subject.new(@interval) }

        context "#interval" do
          should "return the interval" do
            @interval = 5
            assert_equal @interval, subject.interval
          end
        end
      end
    end
  end
end
