#!/usr/bin/env ruby

puts "Hello World"




#@result = IO.popen(["C:\\Python33\\python.exe", "public/process_data.py"])
@result = IO.popen(["C:\\Python33\\python.exe", "public/process_data.py", "laptops", "10", "5"])
arr = @result.gets
puts arr


