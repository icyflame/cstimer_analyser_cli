require "cstimer_analyser_cli/version"
require "optparse"
require "MainCalculations.rb"
require "highline"
require "cli-console"

module CstimerAnalyserCli
	def self.main
		# code to parse the command line options
		options = {}
		OptionParser.new do |opts|
			opts.banner = "Usage: cstimer-analyse [options]"

			opts.on("-v", "--[no-]verbose", "Run verbosely") do |v|
				options[:verbose] = v
			end
			opts.on("-i=INPUT", "--input-file=INPUT", "Input file path") do |i|
				options[:input_file] = i
				#if not i
				#p "You need to pass an input file!"
				#end
			end
			opts.on("-j=INPUT", "--input-json-file=INPUT", "Input file path - in case using the export option") do |filename|
				options[:input_file] = filename
				options[:input_json] = true
			end

			opts.on("-s=SESSION", "--session=SESSION", "Name of the session to analyse") do |session|
				options[:session] = session
				if options[:input_json] and not session
					p "You can't proceed!"
				end
			end

			# TODO - add support for multiple sessions
		end.parse!

		# validation section

		# do not allow user to proceed without input file
		if not options[:input_file]
			puts 'You need to supply an input file path'
			exit 1
		end

		# if JSON file was entered, session must be entered as well
		if options[:input_json] and not options[:session]
			p 'You must provide the name of a session'
			exit 1
		end

		calculater = MainCalculations.new(options[:input_file], options[:input_json] ? true : false, options[:session])

		io = HighLine.new
		console = CLI::Console.new(io)

		console.addCommand('hello', calculater.method(:hello), "Say hello!")
		console.addAlias('hi', 'hello')

		console.addCommand('count', calculater.method(:number_of_points), "Number of datapoints!")

		console.addCommand('statistics', calculater.method(:basic_stats), "Show some basic statistics")
		console.addAlias('stats', 'statistics')

		console.addCommand('average', calculater.method(:build_history_of_averages), "Show the evolution of averages over time")
		console.addAlias('avg', 'average')

		console.addCommand('best', calculater.method(:build_history_of_best_solves), "show the evolution of best solves over time")

		console.addCommand('last', calculater.method(:build_graph_of_last_few_solve_times), "show the history of the last n solves, helpful for session quality")

		console.addCommand('distribute', calculater.method(:build_hist_of_time_distribution), "Plot a distribution graph of times, helpful for locating clusters")
		console.addAlias('dist', 'distribute')

		console.addCommand('history', calculater.method(:build_graph_of_solve_times), "A complete history of your solves over time")

		console.addHelpCommand('help', 'Help')
		console.addExitCommand('exit', 'Exit from program')
		console.addAlias('quit', 'exit')

		console.start("%s> ",["analyse"])

	end
end
