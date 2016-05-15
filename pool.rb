require "lib/blocking_executor"
require "lib/queue"

def println(x)
  print "[#{Thread.current.object_id}] #{x}\n"
end

def word
  ('a'..'z').to_a.sample(3 + rand(3)).join
end

def sentence
  (3 + rand(5)).times.map { word }.join(" ")
end  


Thread.new do
  queue = Queue.new("demo")
  send_pool = BlockingExecutor.new(3)
  println "start sending"
  50.times do |i|
    send_pool.execute do
      queue.send("#{i} #{sentence}")
      println "sent #{i}"
    end
  end
end

q = Queue.new("demo")
pool = BlockingExecutor.new(3)
loop do
  message = q.receive
  pool.execute do 
    println "handle #{message.body}"
    q.delete message.receipt_handle
  end if message
end
