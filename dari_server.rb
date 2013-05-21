require 'rubygems'
require 'sinatra'
require 'rvg/rvg'
include Magick

Tilt.register Tilt::ERBTemplate, 'html'

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
	result = ""
	@temperature_a = ['1','2','3','4', '5']
	@temperature_a.each do |inv|
	    result << (inv + ",")
	end
	File.open('public/data.csv', 'w') { |file| file.write(result.chop) }

	arr = IO.popen(["C:\\Python33\\python.exe", "public/process_data.py"]).gets
	erb :summary_plots, :locals => {:arr => arr, :analysis => params[:Analysis], :os => params[:OS], :classification => params[:Classification]}
end
