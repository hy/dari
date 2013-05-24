require 'rubygems'
require 'sinatra'
require 'rvg/rvg'
include Magick

Tilt.register Tilt::ERBTemplate, 'html'

class Array
  def every(n)
    select {|x| index(x) % n == 0}
  end
  def every_other
    every 2
  end
  def pct(n)
  	self[key * self.length/100]
  end
end

get'/' do
	"<h1>Welcome to the DARI Server!</h1><a href='/choose_data.htm'>data chooser UI</a><br><a href='/choose_data.htm'>data chooser UI</a>"
end


get '/py' do
	@result = IO.popen(["C:\\Python33\\python.exe", "public/process_data.py"])
	#puts @result.gets
	arr = @result.gets
	puts arr
	erb :summary_plots, :locals => {:arr => arr}
end

post '/download' do
	headers "Content-Disposition" => "attachment;filename=test_output.csv", "Content-Type" => "application/octet-stream"
	puts params[:raw_data]
	result = params[:raw_data]
end


post '/plot_selected' do
	#@result = IO.popen(["C:\\Python33\\python.exe", "public/process_data.py"]+params[:plot_class])
	#arr = @result.gets
	arr = IO.popen(["C:\\Python33\\python.exe", "public/process_data.py"]+params[:plot_class]).gets
	erb :summary_plots, :locals => {:arr => arr, :analysis => params[:Analysis], :os => params[:OS], :classification => params[:Classification]}
end

get '/plotter' do
	#result = ""
	@temperature_a = ['1','2','3','4', '5'] #remove
	#@temperature_a.each do |inv|
	#    result << (inv + ",")
	#end
	#File.open('public/data.csv', 'w') { |file| file.write(result.chop) }
	@temperature_a.sort
	array_info = [{
		name: "unnamed series",
		p5: arr.pct(5),
		p95: arr.pct(95),
		mean: @temperature_a.reduce(:+).to_f / @temperature_a.size,
		median: arr.pct(50)
		}]
	result = {
		arrays: [@temperature_a], 
		series_names: ['unnamed series'], 
		max: @temperature_a.last, 
		min: @temperature_a.first,
		array_info: array_info}


	arr = IO.popen(["C:\\Python33\\python.exe", "public/process_data.py"]).gets
	erb :summary_plots, :locals => {:arr => arr, :analysis => params[:Analysis], :os => params[:OS], :classification => params[:Classification]}
end
