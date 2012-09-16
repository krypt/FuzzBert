class FuzzBert::Executor

  attr_reader :pool_size, :limit, :handler

  DEFAULT_POOL_SIZE = 4
  DEFAULT_LIMIT = -1
  DEFAULT_HANDLER = FuzzBert::Handler::FileOutput

  def initialize(suites, args = { 
    pool_size: DEFAULT_POOL_SIZE,
    limit: DEFAULT_LIMIT,
    handler: DEFAULT_HANDLER.new
  })
    @pool_size = args[:pool_size] || DEFAULT_POOL_SIZE
    @limit = args[:limit] || DEFAULT_LIMIT
    @handler = args[:handler] || DEFAULT_HANDLER.new
    @data_cache = {}
    @n = 0
    @exiting = false
    @producer = DataProducer.new(suites)
  end

  def run
    trap_child_exit
    trap_interrupt

    @pool_size.times { run_instance(*@producer.next) }
    @running = true
    @limit == -1 ? sleep : conditional_sleep
  end

  private

  def run_instance(description, test, generator)
    data = generator.to_data
    pid = fork do
      begin
        test.run(data)
      rescue StandardError
        abort
      end
    end
    id = "#{description}/#{generator.description}"
    @data_cache[pid] = [id, data]
  end

  def trap_child_exit
    trap(:CHLD) do 
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
            run_instance(*@producer.next) 
          else
            @running = false
          end
        end
      rescue Errno::ECHILD
      end
    end
  end

  def trap_interrupt
    trap(:INT) do
      exit! (1) if @exiting
      @exiting = true
      graceful_exit
    end
  end

  def graceful_exit
    puts "\nExiting...Interrupt again to exit immediately"
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
    sleep 0.1 until @running == false
  end

  class DataProducer
    def initialize(suites)
      @ring = Ring.new(suites)
      update
    end

    def update
      @suite = @ring.next
      @gen_iter = ProcessSafeEnumerator.new(@suite.generators)
    end

    def next
      gen = nil
      until gen
        begin
          gen = @gen_iter.next
        rescue StopIteration
          update
        end
      end
      [@suite.description, @suite.test, gen]
    end
      
    class Ring
      def initialize(objs)
        @i = 0
        objs = [objs] unless objs.respond_to?(:each)
        @objs = objs.to_a
      end

      def next
        obj = @objs[@i]
        @i = (@i + 1) % @objs.size
        obj
      end
    end

    #needed because the Fiber used for normal Enumerators has race conditions
    class ProcessSafeEnumerator
      def initialize(ary)
        @i = 0
        @ary = ary.to_a
      end

      def next
        obj = @ary[@i]
        raise StopIteration unless obj
        @i += 1
        obj
      end
    end
  end

end

