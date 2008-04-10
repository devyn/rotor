
def Rotor.import(lib)
	l = lib.gsub(".", "::").gsub(/::/, '/').gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').gsub(/([a-z\d])([A-Z])/,'\1_\2').tr("-", "_").downcase
	require l
	true
end

class Rotor::Interpreter
	COMMANDS = {}
	def initialize(rsc)
		@rsc = rsc
		@vars = {}
	end
	
	def run
		@last = nil
		@rsc.byc.each_with_index do |zq, zin|
			zq[1].each_with_index do |ap,win|
				if ap.class == Rotor::RotoScript
					ran = Rotor::Interpreter.new(ap)
					ran.instance_variable_set("@vars", @vars)
					zq[1][win] = ran.run
					@vars = ran.instance_variable_get("@vars")
				end
			end
			puts "Interpreter:\tCommand:\t#{zq[0].downcase}" if Rotor.DEBUG
			case zq[0].downcase
				when "class"
					@vars[zq[1][0][0].intern] = Rotor::Class.new(Object, zq[1][0][0]); @last=true
					puts "Interpreter:\tNew Class:\t$#{zq[1][0][0]}" if Rotor.DEBUG
				when "bind"
					@vars[zq[1][0][0].intern].rmethod_bind(zq[1][1]); @last=true
					puts "Interpreter:\tBind method to:\t#{zq[1][0][0]}" if Rotor.DEBUG
				when "method"
					ary = []
					ary << zq[1][0][0]
					ary << File.open("#{zq[1][0][0]}.rs", "r").read
					ary << false
					zq[1][1..-1].each do |saq|
						ary << saq[0]
					end
					@last = Rotor::Method.new(*ary)
					puts "Interpreter:\tLoad method:\t#{zq[1][0][0]}(.rs)" if Rotor.DEBUG
				when "extern"
					ary = []
					ary << zq[1][0][0]
					ary << File.open("#{zq[1][0][0]}.rsb", "r").read
					ary << true
					zq[1][1..-1].each do |saq|
						ary << saq[0]
					end
					@last = Rotor::Method.new(*ary)
					puts "Interpreter:\tLoad precompiled method:\t#{zq[1][0][0]}(.rsb)" if Rotor.DEBUG
				when "command"
					Rotor::Interpreter::COMMANDS[zq[1][0][0].downcase] = zq[1][1]
					@last = nil
					puts "Interpreter:\tNew command:\t#{zq[1][0][0].downcase}" if Rotor.DEBUG
				when "import"
					zq[1].each do |pth|
						Rotor.import pth.to
						puts "Interpreter:\tImport:\t#{pth.to}" if Rotor.DEBUG
					end
					@last = true
				when "globals"
					@last = @vars
					puts "Interpreter:\tGetGlobals" if Rotor.DEBUG
				when "call"
					@last = zq[1][0].call(*(zq[1][1..-1]))
					puts "Interpreter:\tCall:\t#{zq[1][0].to rescue "undefined"}"
				when "callon"
					@last = zq[1][0].send(zq[1][1][0].intern, *zq[1][2..-1])
					puts "Interpreter:\tCallOn:\t#{zq[1][1][0]}"
				when "callvar"
					@last = @vars[zq[1][0][0].intern].send(zq[1][1][0].intern, *zq[1][2..-1])
				when "set"
					@vars[zq[1][0][0].intern] = zq[1][1]
					@last = zq[1][1]
				when "get"
					@last = @vars[zq[1][0][0].intern]
				when "new"
					@last = zq[1][0].call.new(*(zq[1][1..-1]))
				when "comment"
					@last = nil
				when "valueof"
					@last = zq[1][0]
				when "add"
					@last = zq[1][0] + zq[1][1]
				when "subt"
					@last = zq[1][0] - zq[1][1]
				when "ti"
					@last = zq[1][0] * zq[1][1]
				when "div"
					@last = zq[1][0] / zq[1][1]
				when "exp"
					@last = zq[1][0] ** zq[1][1]
				when "equ"
					@last = zq[1][0] == zq[1][1]
				when "out"
					puts zq[1][0]
					@last = true
				when "nout"
					print zq[1][0]
					@last = true
				when "quit"
					@last = nil
					Kernel.exit
				else
					if Rotor::Interpreter::COMMANDS.keys.include?(zq[0].downcase)
						@last = Rotor::Interpreter::COMMANDS[zq[0].downcase].call(*zq[1])
					else
						@last = nil
						warn "Rotor: Syntax Error on command #{zin}: keyword not found: #{zq[0]}"
					end
			end
		end
		return @last
	end
end

