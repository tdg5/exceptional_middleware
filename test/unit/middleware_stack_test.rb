require "test_helper"
require "exceptional_middleware/middleware_stack"

module ExceptionalMiddleware
  class MiddlewareStackTest < TestCase
    Subject = ExceptionalMiddleware::MiddlewareStack

    context Subject.name do
      subject { Subject }

      context "ancestry" do
        should "include Enumerable" do
          assert_includes subject.ancestors, Enumerable
        end
      end

      context "instance" do
        subject { Subject.new }

        context "#delete" do
          should "raise ArgumentError if a matching existing middleware is not found" do
            assert_raises(ArgumentError) do
              subject.delete(:not_a_middleware, :some_args, :more => :args)
            end
          end

          should "delete the matched middleware" do
            middleware = :some_middleware
            args = [:some_args, :other => :args]
            subject.use(middleware, *args)
            assert_equal 1, subject.middlewares.length
            assert_equal subject.first, [middleware, args]
            subject.delete(middleware, *args)
            assert_equal 0, subject.middlewares.length
          end
        end

        context "#each" do
          should "yield each middleware" do
            subject.use(:foo)
            subject.use(:bar)
            subject.use(:baz)

            middlewares = subject.middlewares
            yield_count = 0
            subject.each do |middleware|
              assert_equal middlewares[yield_count], middleware
              yield_count += 1
            end
            assert_equal middlewares.length, yield_count
          end

          should "yield middleware with arguments" do
            middleware = :foo
            args = [:some, :args => :foo]
            subject.use(middleware, *args)

            yielded = false
            subject.each do |yielded_middleware, yielded_args|
              yielded = true
              assert_equal middleware, yielded_middleware
              assert_equal args, yielded_args
            end
            assert_equal true, yielded
          end

          should "yield no middlewares when none exist" do
            yielded = false
            subject.each do |middleware|
              yielded = true
            end
            assert_equal false, yielded
          end
        end

        context "#insert_after" do
          should "raise ArgumentError if a matching existing middleware is not found" do
            assert_raises(ArgumentError) do
              subject.insert_before(:not_a_middleware, [], :new_middleware)
            end
          end

          should "insert the new middleware after the existing middleware" do
            first_middleware = :first
            first_args = [:first_args, :args => :foobar]
            subject.use(first_middleware, *first_args)

            second_middleware = :second
            second_args = [:second_args, :args => :foobar]
            subject.use(second_middleware, *second_args)

            new_middleware = :new
            new_args = [:new_args, :more => :args]
            subject.insert_after(first_middleware, first_args, new_middleware, *new_args)

            expected_middlewares = [[
              first_middleware, first_args,
            ], [
              new_middleware, new_args,
            ], [
              second_middleware, second_args,
            ]]
            assert_equal expected_middlewares, subject.middlewares
          end
        end

        context "#insert_before" do
          should "raise ArgumentError if a matching existing middleware is not found" do
            assert_raises(ArgumentError) do
              subject.insert_after(:not_a_middleware, [], :new_middleware)
            end
          end

          should "insert the new middleware before the existing middleware" do
            first_middleware = :first
            first_args = [:first_args, :args => :foobar]
            subject.use(first_middleware, *first_args)

            second_middleware = :second
            second_args = [:second_args, :args => :foobar]
            subject.use(second_middleware, *second_args)

            new_middleware = :new
            new_args = [:new_args, :more => :args]
            subject.insert_before(second_middleware, second_args, new_middleware, *new_args)

            expected_middlewares = [[
              first_middleware, first_args,
            ], [
              new_middleware, new_args,
            ], [
              second_middleware, second_args,
            ]]
            assert_equal expected_middlewares, subject.middlewares
          end
        end

        context "#middlewares" do
          setup do
            subject.use(:foo)
            subject.use(:bar)
            subject.use(:baz)
            @middlewares = subject.middlewares
          end

          should "return an accurate middleware stack" do
            assert_equal 3, @middlewares.length
            assert_equal([[:foo, []], [:bar, []], [:baz, []]], @middlewares)
          end

          should "return a copy of the middleware stack" do
            real_middlewares = subject.instance_variable_get(:@middlewares)
            refute_equal(real_middlewares.object_id, @middlewares.object_id)
          end
        end

        context "#swap" do
          setup do
            @existing_middleware = :some_middleware
            @existing_args = []
            @new_middleware = :new_middleware
            @new_args = []
          end

          should "raise if a matching existing middleware cannot be found" do
            assert_raises(ArgumentError) do
              subject.swap(
                @existing_middleware,
                @existing_args,
                @new_middleware,
                *@new_args
              )
            end
          end

          should "raise ArgumentError if middleware exists by arguments are mismatched" do
            @existing_args = [:foo, :bar => :baz]
            subject.use(@existing_middleware, *@existing_args)
            assert_raises(ArgumentError) do
              subject.swap(
                @existing_middleware,
                [:some, :other => :args],
                @new_middleware,
                *@new_args
              )
            end
          end

          should "replace a matching exisitng middleware" do
            subject.use(@existing_middleware, *@existing_args)
            subject.swap(
              @existing_middleware,
              @existing_args,
              @new_middleware,
              *@new_args
            )
            middlewares = subject.middlewares
            assert_equal 1, middlewares.length
            assert_equal [@new_middleware, @new_args], middlewares.first
          end
        end

        context "#use" do
          setup { @middleware = :some_middleware }

          should "add the given middleware and args to the end of the stack" do
            args = [:foo, :bar => :baz]
            subject.use(@middleware, *args)
            assert_equal 1, subject.middlewares.length
            assert_equal [@middleware, args], subject.middlewares[0]
          end

          should "add the given middleware without args to the end of the stack" do
            subject.use(@middleware)
            assert_equal 1, subject.middlewares.length
            assert_equal [@middleware, []], subject.middlewares[0]
          end
        end
      end
    end
  end
end
