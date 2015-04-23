require "remotely_exceptional"

# Remote exception handling via a middleware chain.
module ExceptionalMiddleware
  # The namespace underwhich Handler components live.
  module Handler
  end

  # The namespace underwhich Matcher components live.
  module Matcher
  end

  # The namespace underwhich Middleware components live.
  module Middleware
  end

  # The namespace underwhich Strategy components live.
  module Strategy
  end
end
