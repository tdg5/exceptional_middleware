require "test_helper"
require "test_helpers/strategy/simple_retry_strategy"
require "test_helpers/strategy/exponential_retry_strategy"
require "mad_libs/flake/random_exponential_backoff_flake"
require "remotely_exceptional/remote_handling"

module ExceptionalMiddleware
  class ExponentialRetryScenarioTest < TestCase
    include RemotelyExceptional::RemoteHandling

    Flake = MadLibs::Flake::RandomExponentialBackoffFlake
    Strategy = ExceptionalMiddleware::Test::Strategy::ExponentialRetryStrategy

    SUCCESS_FREQUENCY = 3

    context Strategy.name do
      subject { Strategy }

      context "randomly flaky endpoint requiring exponential backoff" do
        should "succeed eventually" do
          expected_success_count = 10
          success_count = 0

          flake = Flake.new(SUCCESS_FREQUENCY)
          expected_success_count.times do
            remotely_exceptional(subject) do
              flake.call
              success_count += 1
            end
          end
          assert_equal expected_success_count, success_count
          assert_equal true, flake.stats[:calls][:failure] > 0
        end
      end
    end
  end
end
