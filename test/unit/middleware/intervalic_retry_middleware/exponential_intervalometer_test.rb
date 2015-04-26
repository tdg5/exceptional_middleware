require "test_helper"
require "exceptional_middleware/middleware/intervalic_retry_middleware/exponential_intervalometer"

module ExceptionalMiddleware::Middleware::IntervalicRetryMiddleware
  class ExponentialIntervalometerTest < ExceptionalMiddleware::TestCase
    Subject = ExponentialIntervalometer

    module TestIncluder
      include Subject
    end

    context Subject.name do
      subject { Subject }

      context "including class" do
        subject { TestIncluder }

        context "::exponential_term" do
          should "return the expected terms" do
            max_term = 1000
            term = last_term = 1
            loop do
              assert_equal 2 ** term, subject.exponential_term(term)
              term, last_term = rand(last_term) + term + 1, term
              break if term > max_term
            end
          end
        end

        context "::interval" do
          should "return intervals within 10% + 0.25 of the term divided by 1000ms" do
            (remote_exception = mock).stubs(:context).returns(context = {})
            (1..20).each do |index|
              context[:retry_count] = index
              interval = subject.interval(remote_exception)
              assert_in_delta(2 ** index / 1000.0, interval, interval * 0.1 + 0.25)
            end
          end
        end
      end
    end
  end
end
