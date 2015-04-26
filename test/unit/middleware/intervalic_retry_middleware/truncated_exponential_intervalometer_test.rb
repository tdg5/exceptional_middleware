require "test_helper"
require "exceptional_middleware/middleware/intervalic_retry_middleware/truncated_exponential_intervalometer"

module ExceptionalMiddleware::Middleware::IntervalicRetryMiddleware
  class TruncatedExponentialIntervalometerTest < ExceptionalMiddleware::TestCase
    Subject = TruncatedExponentialIntervalometer

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
              next if interval == subject.max_interval
              assert_in_delta(2 ** index / 1000.0, interval, interval * 0.1 + 0.25)
            end
          end

          should "return the expected regular and truncated intervals" do
            (remote_exception = mock).stubs(:context).returns(context = {})
            max_term = 1000
            found_regular_intervals = found_truncated_intervals = false
            term = last_term = 1
            loop do
              context[:retry_count] = term
              result = subject.interval(remote_exception)
              if result < subject.max_interval
                found_regular_intervals = true
              else
                assert_equal subject.max_interval, result
                found_truncated_intervals = true
              end
              term, last_term = rand(last_term) + term + 1, term
              break if term > max_term
            end
            assert_equal true, found_regular_intervals && found_truncated_intervals
          end
        end
      end
    end
  end
end
