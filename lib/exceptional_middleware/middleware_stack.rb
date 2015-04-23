module ExceptionalMiddleware
  class MiddlewareStack
    include Enumerable

    # Create a new MiddlewareStack.
    def initialize
      @middlewares = []
    end

    # Delete an existing middleware with matching arguments from the middleware
    # stack.
    #
    # @param existing_middleware [Object] The existing middleware object.
    # @param existing_args [Array<Object>] The arguments of the existing
    #   middleware object.
    # @raise [ArgumentError] If a matching existing middleware cannot be found.
    # @return [true] Returns true if an existing middleware was deleted.
    def delete(existing_middleware, *existing_args)
      assert_index(existing_middleware, *existing_args)
      @middlewares.delete([existing_middleware, existing_args])
      true
    end

    def each
      middlewares.each { |mw| yield mw }
    end

    # Inserts a new middleware after an existing_middleware.
    #
    # @param existing_middleware [Object] The existing middleware object.
    # @param existing_args [Array<Object>] The arguments of the existing
    #   middleware object.
    # @param middleware [Object] The middleware to add after the existing
    #   middleware.
    # @param args [Object] The arguments for the new middleware.
    # @raise [ArgumentError] If a matching existing middleware cannot be found.
    # @return [true] Returns true if the given middleware was added before an
    #   existing middleware.
    def insert_after(existing_middleware, existing_args, middleware, *args)
      index = assert_index(existing_middleware, *existing_args)
      insert(index + 1, middleware, *args)
      true
    end

    # Inserts a new middleware before an existing middleware.
    #
    # @param existing_middleware [Object] The existing middleware object.
    # @param existing_args [Array<Object>] The arguments of the existing
    #   middleware object.
    # @param middleware [Object] The middleware to add to the stack before an
    #   existing middleware.
    # @param args [Object] The arguments for the new middleware.
    # @raise [ArgumentError] If a matching existing middleware cannot be found.
    # @return [true] Returns true if the given middleware was added after an
    #   existing middleware.
    def insert_before(existing_middleware, existing_args, middleware, *args)
      index = assert_index(existing_middleware, *existing_args)
      insert(index, middleware, *args)
      true
    end

    # Returns a new list of the registered middlewares and their arguments.
    #
    # @return [Array<Array<Object, Array<Object>>>] Returns an Array of
    #   middleware pairs. The first element in the pair is the middleware and
    #   the second element in the pair is any arguments for the middleware.
    def middlewares
      @middlewares.dup
    end

    # Swaps an existing middleware for a new middleware.
    #
    # @param existing_middleware [Object] The existing middleware object.
    # @param existing_args [Array<Object>] The arguments of the existing
    #   middleware object.
    # @param middleware [Object] The middleware to replace the existing
    #   middleware with.
    # @param args [Object] The arguments for the new middleware.
    # @raise [ArgumentError] If a matching existing middleware cannot be found.
    # @return [true] Returns true if the given middleware replaced an existing
    #   middleware.
    def swap(existing_middleware, existing_args, middleware, *args)
      existing_index = assert_index(existing_middleware, *existing_args)
      @middlewares[existing_index] = [middleware, args]
      true
    end

    # Adds a new middleware to the end of the middleware stack.
    #
    # @param middleware [Object] The middleware to replace the existing
    #   middleware with.
    # @param args [Object] The arguments for the new middleware.
    # @raise [ArgumentError] If a matching existing middleware cannot be found.
    # @return [true] Returns true if the given middleware was added to the
    #   middleware stack.
    def use(middleware, *args)
      @middlewares << [middleware, args]
      true
    end

    protected

    def assert_index(existing_middleware, *existing_args)
      existing_pair = [existing_middleware, existing_args]
      idx = @middlewares.index(existing_pair)
      raise ArgumentError, "Could not find matching middleware for #{existing_pair.inspect}" unless idx
      idx
    end

    def insert(index, middleware, *args)
      @middlewares.insert(index, [middleware, args])
    end
  end
end
