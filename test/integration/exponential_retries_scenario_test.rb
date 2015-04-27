require "test_helper"
require "test_helpers/test_strategies"
require "remotely_exceptional/remote_handling"

module ExceptionalMiddleware
  class ExponentialRetriesScenarioTest < TestCase
    include RemotelyExceptional::RemoteHandling
    Flake = ExceptionalMiddleware::Test::Flakes::ExponentialRetry
    SimpleRetryStrategy = ExceptionalMiddleware::Test::Strategy::SimpleRetryStrategy
    ExponentialRetryStrategy = ExceptionalMiddleware::Test::Strategy::ExponentialRetryStrategy

    strategies = [
      # SimpleRetryStrategy,
      ExponentialRetryStrategy,
    ]

    strategies.each do |strategy|
      context strategy.name do
        subject { strategy }

        context "lalal" do
          should "" do
            flake = Flake.new(subject)
            25.times { remotely_exceptional(subject) { flake.call } }
            puts flake.stats
          end
        end
      end
    end
  end
end
