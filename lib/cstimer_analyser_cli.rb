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
				if not i
					p "You need to pass an input file!"
				end
			end
		end.parse!

		#VERBOSE = options[:verbose]

		#if VERBOSE
		#p "Options read from the command line:"
		#p options
		#end

		# do not allow user to proceed without input file
		if not options[:input_file]
			puts "You need to supply an input file path"
			exit
		end

		calculater = MainCalculations.new(options[:input_file])

		io = HighLine.new
		console = CLI::Console.new(io)

		console.addCommand('hello', calculater.method(:hello), "Say hello!")
		console.addAlias('hi', 'hello')

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
