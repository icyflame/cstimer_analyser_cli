require "gnuplot"
require "statsample"
require "cli-console"

class MainCalculations
	private
	extend CLI::Task

	public

	attr_accessor :file_name, :all_times

	def initialize(file_name, json=false, session="")
		@file_name = file_name
		@all_times = Array.new
		@json_file = json
		@session = session
		read_from_file
	end

	usage 'Say Hello to the user'
	desc 'Imitating human warmth in a computer program!'
	def hello(params)
		puts "Hello, what's up?"
		puts "You gave me #{params.inspect} as parameters"
	end

	def read_from_file
		if @json_file
			start_reading = false
			require 'json'
			file_obj = JSON.parse(File.read(@file_name))

			# check if given session is in the file
			if not file_obj.keys.include?(@session)
				p "Provided session (#{@session})was not there in the file"
				p 'Session names are generally session2, session3, etc'
				exit 1
			end

			# session is in the file

			session_obj = JSON.parse(file_obj[@session])
			p session_obj.length

		else
			start_reading = false
			# read the input file
			File.open(@file_name, "r") do |filin|
				while(line = filin.gets)
					if not start_reading and /Time\sList/.match(line)
						start_reading = true
					end

					if start_reading
						matches = line.scan(/\d{2}.\d{2}/)
						matches.each do |match|
							@all_times.push(match.to_f)
						end
					end
				end
			end
			@main_vector = @all_times.to_vector(:scale)
		end
	end

	usage 'Output the number of solves that were provided by the user'
	desc 'This is a quick check to ensure that the file provided by the user was imported'
	def number_of_points(params)
		p "#{@all_times.count} solves were in the input file"
	end

	usage 'Show some basic statistics about the solvetimes'
	desc 'Statistics include average, standard deviation, best and worst times'
	def basic_stats(params)
		p '----------------------------'
		p '----------------------------'
		p '-------- STATISTICS --------'
		p 'Mean of the solvetimes   : %0.2f' % @main_vector.mean
		p 'Median of the solvetimes : %0.2f' % @main_vector.median
		p 'Best solvetime           : %0.2f' % @main_vector.min
		p 'Worst solvetime          : %0.2f' % @main_vector.max
		p 'Mode solvetime           : %0.2f' % @main_vector.mode
	end

	usage 'Show a history of averages, and how they changed over time'
	desc 'avg 100: will show a history of your distinct average of 100 solves'
	def build_history_of_averages(params)
		raise ArgumentError, "What is the number of solves to computer average for?" unless params.count >= 1
		num_solves = params[0].to_i
		num_datapoints = (@all_times.count / num_solves).to_i
		all_means = Array.new
		for i in 0..num_datapoints
			this_mean = @all_times[i*num_solves..(i+1)*num_solves].to_vector.mean
			all_means.push(this_mean)
		end
		Gnuplot.open do |gp|
			Gnuplot::Plot.new( gp ) do |plot|

				plot.title  "Average of #{num_solves} versus time (Total of #{@all_times.count} solves)"
				plot.xlabel "n-th set of #{num_solves} solves"
				plot.ylabel "Average of #{num_solves}"
				plot.xrange "[0:#{all_means.count+2}]"

				y = all_means
				x = (1..all_means.count).to_a

				plot.data << Gnuplot::DataSet.new( [x, y] ) do |ds|
					ds.with = "linespoints"
					ds.notitle
				end
			end
		end
	end

	usage 'Build a history of your best solves over time'
	desc 'best 100: plots the best solve among 100 discontinuous and non-overlapping solves'
	def build_history_of_best_solves(params)
		raise ArgumentError, "What is the number of solves to computer average for?" unless params.count >= 1
		num_solves = params[0].to_i
		num_datapoints = (@all_times.count / num_solves).to_i
		all_best_times = Array.new
		for i in 0..num_datapoints
			this_min = @all_times[i*num_solves..(i+1)*num_solves].to_vector.min
			all_best_times.push(this_min)
		end
		Gnuplot.open do |gp|
			Gnuplot::Plot.new( gp ) do |plot|

				plot.title  "Best of #{num_solves} versus time (Total of #{@all_times.count} solves)"
				plot.xlabel "n-th set of #{num_solves} solves"
				plot.ylabel "Best of #{num_solves}"
				plot.xrange "[0:#{all_best_times.count+2}]"

				y = all_best_times
				x = (1..all_best_times.count+2).to_a

				plot.data << Gnuplot::DataSet.new( [x, y] ) do |ds|
					ds.with = "linespoints"
					ds.notitle
				end
			end
		end
	end

	usage 'Build a line graph of your solvetime evolution'
	desc 'history: A congested graph showing when your best and lowest times were achieved, helpful in noticing patterns'
	def build_graph_of_solve_times(params)
		Gnuplot.open do |gp|
			Gnuplot::Plot.new( gp ) do |plot|

				plot.title  "Solvetime evolution over time (Total of #{@all_times.count} solves)"
				plot.xlabel "Time"
				plot.ylabel "Solvetimes"

				y = @all_times
				x = (1..@all_times.count).to_a

				plot.data << Gnuplot::DataSet.new( [x, y] ) do |ds|
					ds.with = "linespoints"
					ds.notitle
				end
			end
		end
	end

	usage 'Solvetime evolution for the last few times, want to know how that last session went?'
	desc 'last 100: plots the last 100 solve times with index on the horizontal axis'

	def build_graph_of_last_few_solve_times(params)
		raise ArgumentError, "What is the number of solves to computer average for?" unless params.count >= 1
		num_solves = params[0].to_i
		Gnuplot.open do |gp|
			Gnuplot::Plot.new( gp ) do |plot|

				plot.title  "Last #{num_solves} solvetimes (Total of #{@all_times.count} solves)"
				plot.xlabel "Time"
				plot.ylabel "Solvetime"

				#start_index = @all_times.count - num_solves
				#end_index = @all_times.count-1

				y = @all_times[@all_times.count-num_solves..@all_times.count-1]
				x = (@all_times.count-num_solves..@all_times.count-1).to_a

				plot.data << Gnuplot::DataSet.new( [x, y] ) do |ds|
					ds.with = "linespoints"
					ds.notitle
				end
			end
		end
	end

	usage 'Find where most of your times lie'
	desc 'distribute 20 25 0.5: will show a histogram with 10 bins, with the first bin at 20-20.5 and the last bin for 24.5-25, and the height of the bin being the number of solves in that interval'
	def build_hist_of_time_distribution(params)
		raise ArgumentError, "What is the number of solves to computer average for?" unless params.count >= 3
		start_time = params[0].to_f
		end_time = params[1].to_f
		min_distance = params[2].to_f

		main_hash = Hash.new(0)
		num_bins = ((end_time - start_time) / min_distance).to_f.ceil

		printf "Number of bins is %d\n", num_bins

		@all_times.each do |time|
			if time >= start_time and time <= end_time
				main_hash[((time - start_time) / min_distance).floor] += 1
			end
		end

		puts main_hash.count
		puts main_hash.to_s

		data = Array.new

		for i in main_hash
			data.push([i, main_hash[i]])
		end

		Gnuplot.open do |gp|
			Gnuplot::Plot.new(gp) do |plot|

				plot.title  "Time Distribution (Total of #{@all_times.count} solves)"
				plot.style  "data histograms"
				plot.xtics	"nomirror rotate"
				plot.boxwidth "0.5"
				# plot.xtics  "nomirror rotate by +45"

				x = Array.new
				y = Array.new

				(0..num_bins-1).to_a.each do |index|
					x.push((start_time + index * min_distance).to_s + "-" + (start_time + (index+1) * min_distance).to_s)
					y.push(main_hash[index])
				end

				plot.yrange "[0:#{main_hash.max_by{|k, v| v}[1] * 1.25}]"

				plot.data = [
					Gnuplot::DataSet.new( [x, y] ) { |ds|
						ds.using = "2:xtic(1)"
						ds.with = "boxes fill solid 0.8"
						# ds.with = "candlesticks"
						ds.title = "Number of solves"
					},
					Gnuplot::DataSet.new( [x, y] ) { |ds|
						ds.using = "0:(10 + $2):2 with labels"
						ds.title = ""
					}
				]
			end
		end
	end
end
