#!/usr/bin/env ruby

require "rotor/all.rb"

if __FILE__ == $0
	require 'optparse'
	require 'ostruct'
	opts = OptionParser.new
	options = OpenStruct.new
	opts.banner = "Usage:  rotor [-h]\n\trotor -c FILE1 FILE2\n\trotor [-b] FILE\n"
	opts.on("-h", "--help", "Show this message.") do
		options.help = true
		puts opts
	end
	opts.on("-d", "--debug", "Run in debug output mode.") do
		Rotor.DEBUG = true
	end
	opts.on("-b", "--byte-code", "Treat as byte-code.") do
		options.byc = true
	end
	opts.on("-c", "--compile", "Generate a (.rsb) file.") do
		options.compile = true
	end
	z = opts.parse(*ARGV)
	if options.byc
		Rotor[2, *z]
	elsif options.compile
		Rotor[1, *z]
	elsif z.size > 0
		Rotor[0, *z]
	else
		Rotor[3] unless options.help
	end
end
