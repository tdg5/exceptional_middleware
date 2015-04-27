require "test_helper"
require "test_helpers/test_strategies"
require "remotely_exceptional/remote_handling"

module ExceptionalMiddleware
  class TenaciousRetriesScenarioTest < TestCase
    include RemotelyExceptional::RemoteHandling
    Flake = ExceptionalMiddleware::Test::Flakes::TryTryAgain
    Subject = ExceptionalMiddleware::Test::Strategy::SimpleRetryStrategy

    context Subject.name do
      subject { Subject }

      context "lalal" do
        should "" do
          flake = Flake.new(subject)
          #25.times { remotely_exceptional(subject) { flake.call } }
          puts flake.stats
        end
      end
    end
  end
end
