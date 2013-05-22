require 'rubygems'
require 'sinatra'
require 'rvg/rvg'
include Magick

Tilt.register Tilt::ERBTemplate, 'html'

get'/' do
	"This is the sinatra demo page!"
end

get'/test' do
	"Hello Lady"
end

get'/try/:id' do
	"Hello #{params[:name]} (#{params[:id]})"
end

get '/duck3.gif' do
	RVG::dpi = 72

	rvg = RVG.new(2.5.in, 2.5.in).viewbox(0,0,250,250) do |canvas|
		canvas.background_fill = 'white'

		canvas.g.translate(100, 150).rotate(-30) do |body|
			body.styles(:fill=>'yellow', :stroke=>'black', :stroke_width=>2)
			body.ellipse(50, 30)
			body.rect(45, 20, -20, -10).skewX(-35)
		end

		canvas.g.translate(130, 83) do |head|
			head.styles(:stroke=>'black', :stroke_width=>2)
			head.circle(30).styles(:fill=>'yellow')
			head.circle(5, 10, -5).styles(:fill=>'black')
			head.polygon(30,0, 70,5, 30,10, 62,25, 23,20).styles(:fill=>'orange')
		end

		foot = RVG::Group.new do |_foot|
			_foot.path('m0,0 v30 l30,10 l5,-10, l-5,-10 l-30,10z').
				styles(:stroke_width=>2, :fill=>'orange', :stroke=>'black')
		end
		canvas.use(foot).translate(75, 188).rotate(15)
		canvas.use(foot).translate(100, 185).rotate(-15)

		#canvas.text(125, 30) do |title|
		#	title.tspan("duck|").styles(:text_anchor=>'end', :font_size=>20,
		#		:font_family=>'helvetica', :fill=>'black')
		#	title.tspan("type").styles(:font_size=>22,
		#		:font_family=>'times', :font_style=>'italic', :fill=>'red')
		#end
		canvas.rect(249,249).styles(:stroke=>'blue', :fill=>'none')
	end

	#rvg.draw.write('duck2.gif')
	img = rvg.draw
	content_type 'image/gif'
	img.format = 'gif'
	img.to_blob
	#"<h1>pic</h1> <img src='duck2.gif' />"

end

get '/display' do
	"<h1>pic</h1> <img src='duck3.gif' />

<svg xmlns='http://www.w3.org/2000/svg' version='1.1'>
  <circle cx='100' cy='50' r='40' stroke='black'
  stroke-width='2' fill='red' />
</svg>

	"
end


get '/graphBy' do
  erb :graph1
end

get '/py' do
	@result = IO.popen(["C:\\Python33\\python.exe", "public/process_data.py"])
	#puts @result.gets
	arr = @result.gets
	puts arr
	erb :summary_plots, :locals => {:arr => arr}
end

post '/get_data' do
	#params[:message]
	#pp params # outputs {"info"=>"some_info"} in the console
	headers "Content-Disposition" => "attachment;filename=results.csv",
    "Content-Type" => "application/octet-stream"
	params[:raw_data]
	#send_file(file, :disposition => 'attachment', :filename => File.basename(file))

	file = Tempfile.new('foo.csv')
	begin
		send_file "./files/#{filename}", :filename => filename, :type => 'Application/octet-stream'
	ensure
		file.close
		file.unlink   # deletes the temp file
	end
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

