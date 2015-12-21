require "cstimer_analyser_cli/version"
require "optparse"
require "./MainCalculations.rb"

module CstimerAnalyserCli
	def main
		# code to parse the command line options
		options = {}
		OptionParser.new do |opts|
			opts.banner = "Usage: example.rb [options]"

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

		return MainCalculations.new(options[:input_file]).file_name
	end
end
