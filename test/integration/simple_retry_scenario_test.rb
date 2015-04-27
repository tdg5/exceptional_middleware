require "test_helper"
require "test_helpers/strategy/simple_retry_strategy"
require "mad_libs/flake/random_flake"
require "remotely_exceptional/remote_handling"

module ExceptionalMiddleware
  class SimpleRetryScenarioTest < TestCase
    include RemotelyExceptional::RemoteHandling

    Flake = MadLibs::Flake::RandomFlake
    Subject = ExceptionalMiddleware::Test::Strategy::SimpleRetryStrategy.new(0.01)
    SUCCESS_FREQUENCY = 4

    context Subject.name do
      subject { Subject }

      context "randomly flaky endpoint" do
        should "succeed through sheer retries" do
          expected_success_count = 25
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
