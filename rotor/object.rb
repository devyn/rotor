
class Rotor::Object
	def is?(o)
		self.object_id == o.object_id
	end
	# Put other global-inheritance methods here
end

class Rotor::Pointer
	attr_accessor :to
	def initialize(s, met=false)
		@to = s
		@method = (s =~ /^[ ]*(\.[A-Za-z0-9_]+)*(->[a-z][A-Za-z0-9_]*[\!\?]?)[ ]*$/)
	end
	def call(*args)
		if @method
			return eval(@to.gsub(".", "::").gsub("->", ".") + "(*args)", binding)
		else
			return eval(@to.gsub(".", "::"))
		end
	end
	def rotor_inspect; "\e[32mpointer\e[0m (\e[31m#@to\e[0m)"; end
end

class Rotor::Method
	attr_accessor :name
	def initialize(name, code, binmode, *arn)
		if binmode
			@rs = Rotor.loadbyc(code)
		else
			@rs = Rotor::RotoScript.new(code)
		end
		@name = name
		@arn = arn
	end
	
	def call(*args)
		inter = Rotor::Interpreter.new(@rs)
		hsh = {}
		args.each_with_index do |pet, ind|
			hsh[@arn[ind]] = pet
		end
		inter.instance_variable_set("@vars", hsh)
		inter.run
		inter.instance_variable_set("@last", nil)
		return true
	end
	
	def rotor_inspect; "(\e[31m#@name\e[0m)"; end
end

class Rotor::Class
	attr_accessor :name
	def initialize(superclass, name)
		@name = name
		@class = Class.new(superclass)
	end
	
	def rmethod_bind(met)
		@class.class_eval { define_method(met.name.to_s.intern) { |*args| met.call(*args) } }
	end
	
	def rotor_inspect; "(\e[31m.#@name\e[0m)"; end
	
	def method_missing(id, *args)
		@class.send(id, *args)
	end
end

class Object
	def rotor_inspect
		"(\e[31m.#{self.class.name.gsub("::", ".")}\e[0m:\e[36m0x#{self.object_id.abs.to_s(16)}\e[0m)"
	end
end

class String
	def rotor_inspect; "\e[33m#{inspect}\e[0m"; end
end

class Module
	def rotor_inspect
		"\e[31m.#{self.name.gsub("::", ".")}\e[0m"
	end
end

class Symbol
	def rotor_inspect; "\e[33m#{inspect}\e[0m"; end
end

class Numeric
	def rotor_inspect; "\e[36m#{inspect}\e[0m"; end
end

class Array
	def rotor_inspect
		artex = ""
		self.each_with_index do |itm, ind|
			artex += itm.rotor_inspect
			artex += " & " unless ind == (self.size - 1)
		end
		"{#{artex}}"
	end
end

class NilClass
	def rotor_inspect; "\e[32mnull\e[0m"; end
end

class TrueClass
	def rotor_inspect; "\e[32myes\e[0m"; end
end

class FalseClass
	def rotor_inspect; "\e[32mno\e[0m"; end
end

class Exception
	def rotor_inspect
		"\e[31m.#{self.class.name.gsub("::", ".")}\e[0m: \e[33m#{self.message.split("\n")[0]}\e[0m"
	end
end

class Hash
	def rotor_inspect
		artex = ""
		self.to_a.each_with_index do |itm, ind|
			artex += "#{itm[0].rotor_inspect} : #{itm[1].rotor_inspect}"
			artex += " & " unless ind == (self.to_a.size - 1)
		end
		"{#{artex}}"
	end
end

