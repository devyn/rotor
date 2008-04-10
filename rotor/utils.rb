
require 'yaml'
require 'zlib'

module Rotor
	def compile(code)
		byc = Zlib::Deflate.deflate("# rotor 1.0 bytecode\n" + Rotor::RotoScript.new(code).to_yaml)
	end
	
	def loadbyc(byc)
		YAML.load(Zlib::Inflate.inflate(byc))
	end
	
	def runbyc(byc)
		Rotor::Interpreter.new(loadbyc(byc)).run
	end
	
	def interpret(code)
		Rotor::Interpreter.new(Rotor::RotoScript.new(code)).run
	end
	
	def self.[](mode, *files)
		unless (files.size > 0) or (mode == 3); warn "No files!"
		abort "Try 'rotor --help' for more assistance."; end
		case mode
			when 0
				interpret(File.open(files[0], "r").read)
			when 1
				unless files.size > 1; warn "Less than number of files needed given!"
				abort "Try 'rotor --help' for more assistance."; end
				File.open(files[1], "w") { |f| f.write(compile(File.open(files[0], "r").read)) }
			when 2
				runbyc(File.open(files[0], "r").read)
			when 3
				Rotor::Interface.new.loopeval
			else
				raise ArgumentError, "'#{mode}' is not a valid mode."
		end
		return true
	end
end
