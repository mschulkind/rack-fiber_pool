require 'fiber_pool'

module Rack
  class FiberPool
    VERSION = '0.9.1'
    SIZE = 100

    # The size of the pool is configurable:
    #
    #   use Rack::FiberPool, :size => 25
    def initialize(app, options={})
      puts "I0"
      @app = app
      @fiber_pool = ::FiberPool.new(options[:size] || SIZE)
      puts "I1"
      yield @fiber_pool if block_given?
      puts "I2"
    end

    def call(env)
      puts "C1"
      call_app = lambda do
        result = @app.call(env)
        env['async.callback'].call result
      end

      puts "C2"
      
      @fiber_pool.spawn(&call_app)

      puts "C3"
      throw :async
    end
  end
end
