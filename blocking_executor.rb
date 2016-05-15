class BlockingExecutor < java.util.concurrent.ThreadPoolExecutor 
  
  def initialize(poolSize)
    super(poolSize, poolSize, 0, java.util.concurrent.TimeUnit::MILLISECONDS, 
      java.util.concurrent.LinkedBlockingQueue.new)
    @semaphore = java.util.concurrent.Semaphore.new(poolSize)
  end

  def execute(&task)
    @semaphore.acquire rescue retry
    super(&task)
  rescue java.util.concurrent.RejectedExecutionException
    @semaphore.release
    raise
  end
 
  def afterExecute(runnable, throwable)
    super(runnable, throwable)
    @semaphore.release
  end

end

def println(x)
  print "#{x}\n"
end

be = BlockingExecutor.new(3)
30.times do |i| 
  be.execute { sleep(1); println "exec #{i}" }
  println "queued #{i}"
end
