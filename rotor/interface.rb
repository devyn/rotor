
class Rotor::Interface
	def initialize
		@vars = {:interface => true}
	end
	def prompt
		print "\e[33m>> \e[36m"
		z = nil
		begin
			inter = Rotor::Interpreter.new(Rotor::RotoScript.new(gets.chomp))
			print "\e[0m"
			inter.instance_variable_set("@vars", @vars)
			z = inter.run
			@vars = inter.instance_variable_get("@vars")
		rescue Exception
			z = $!
		end
		puts "\e[33m=> \e[0m#{z.rotor_inspect}"
		z
	end
	def loopeval
		cont = true
		while cont
			if prompt.class == SystemExit
				cont = false
			end
		end
	end
end
