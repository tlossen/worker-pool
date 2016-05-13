require "#{Dir.pwd}/be.jar"
be = Java::BlockingExecutor.new(5)
100.times { |i| be.execute { sleep(2); puts "hello #{i}" }}
