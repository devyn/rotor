
module Rotor ; extend self
	@@debug=false
	def DEBUG
		@@debug
	end
	def DEBUG=(v)
		@@debug = v
	end
end

def libreq(*args)
	args.each {|s| require File.join(File.dirname(__FILE__), s.to_s) }
end

libreq :object, :rotoscript, :interpreter, :interface, :utils
