
class FuzzBert::Executor

  attr_reader :test, :pool_size, :limit, :handler

  DEFAULT_HANDLER = FuzzBert::Handler::FileOutput
  DEFAULT_POOL_SIZE = 4
  DEFAULT_LIMIT = -1

  def initialize(test, args = { 
    handler: DEFAULT_HANDLER.new,
    pool_size: DEFAULT_POOL_SIZE,
    limit: DEFAULT_LIMIT
  })
    @test = test
    @pool_size = args[:pool_size] || DEFAULT_POOL_SIZE
    @limit = args[:limit] || DEFAULT_LIMIT
    @handler = args[:handler] || DEFAULT_HANDLER.new
    @data_cache = {}
    @n = 0
    @running = true
  end

  def run(generators)
    generators = [generators] unless generators.respond_to?(:each)
    producer = GeneratorProducer.new(generators)

    trap(:CHLD) { on_child_exit(producer.next) }
    trap(:INT) { graceful_exit }
    
    @pool_size.times { run_test(producer.next) }
    @running = true
    @limit == -1 ? sleep : conditional_sleep
  end

  private

  def run_test(generator)
    data = generator.to_data
    pid = fork do
      begin
        @test.run(data)
      rescue StandardError
        abort
      end
    end
    id = "#{@test.description}/#{generator.description}"
    @data_cache[pid] = [id, data]
  end

  def on_child_exit(generator)
    begin
      while exitval = Process.wait2(-1, Process::WNOHANG)
        pid = exitval[0]
        status = exitval[1]
        data_ary = @data_cache.delete(pid)
        unless status.success?
          handle(data_ary[0], data_ary[1], pid, status) unless interrupted(status)
        end
        @n += 1
        if @limit == -1 || @n < @limit
          run_test(generator) 
        else
          @running = false
        end
      end
    rescue Errno::ECHILD
    end
  end

  def graceful_exit
    puts "\nExiting..."
    begin
      while Process.wait; end
    rescue Errno::ECHILD
    end
    exit 0
  end

  def handle(id, data, pid, status)
    @handler.handle(id, data, pid, status)
  end

  def interrupted(status)
    return false if status.exited?
    return true if status.termsig == nil || status.termsig == 2
  end

  def conditional_sleep
    sleep 0.5 until @running == false
  end

  class GeneratorProducer
    def initialize(generators)
      @i = 0
      @generators = generators
    end

    def next
      obj = @generators[@i]
      @i = (@i + 1) % @generators.size
      obj
    end
  end

end

