class BlockingExecutor < java.util.concurrent.ThreadPoolExecutor 
  
  def initialize(poolSize)
    super(poolSize, poolSize, 0, java.util.concurrent.TimeUnit::MILLISECONDS, 
      java.util.concurrent.LinkedBlockingQueue.new)
    @semaphore = java.util.concurrent.Semaphore.new(poolSize)
  end

  def execute(&task)
    acquire 
    begin
      super(&task)
    rescue java.util.concurrent.RejectedExecutionException
      @semaphore.release
      raise
    end
  end
 
  def afterExecute(runnable, throwable)
    super(runnable, throwable)
    @semaphore.release
  end

private

  def acquire
    @semaphore.acquire
  rescue java.lang.InterruptedException
    retry
  end

end

be = BlockingExecutor.new(5)
100.times { |i| be.execute { sleep(2); puts "hello #{i}" }}
