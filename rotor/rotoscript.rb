
module Rotor
	def typeof?(s)
		puts "TypeOf:\t#{s}" if self.DEBUG
		bool = /^[ ]*(yes|no|null)[ ]*$/
		int = /^[ ]*[0-9]+(e[0-9]+)?[ ]*$/
		str = /^[ ]*("[^"]*"|'[^']*')[ ]*$/
		char = /^[ ]*\?[A-Za-z0-9][ ]*$/
		sym = /^[ ]*:[^:]+[ ]*$/
		arr = /^[ ]*\{(.*( &)?)*\}[ ]*$/
		embd = /^[ ]*\[[^\]]*\][ ]*$/
		pointer = /^[ ]*(\.[A-Za-z0-9_]+)+[ ]*$/
		mepoint = /^[ ]*(\.[A-Za-z0-9_]+)*(->[a-z][A-Za-z0-9_]*[\!\?]?)[ ]*$/
		embdvar = /^[ ]*\$[a-zA-Z0-9_]+[!?]?[ ]*$/
		var = /^[ ]*[a-zA-Z0-9_]+[!?]?[ ]*$/
		if s =~ bool
			rt = ({"yes" => true, "no" => false, "null" => nil})[s]
		elsif s =~ int
			rt = s.to_i
		elsif s =~ str
			rt = s.gsub(/^[ ]*["']/, "").gsub(/["'][ ]*$/, "")
		elsif s =~ char
			rt = s[1]
		elsif s =~ sym
			rt = s[1..-1].gsub(/^:/, "").intern
		elsif s =~ pointer
			rt = Rotor::Pointer.new(s)
		elsif s =~ mepoint
			rt = Rotor::Pointer.new(s)
		elsif s =~ arr
			rt = Rotor.bulk_typeof?(s.gsub(/^\{|\}$/, "").split(/[ ]*&[ ]*/))
		elsif s =~ embd
			rt = Rotor::RotoScript.new(s.gsub(/^[ ]*\[|\][ ]*$/, ""))
		elsif s =~ embdvar
			rt = Rotor::RotoScript.new("get #{s.gsub("$", "")}")
		elsif s =~ var
			rt = [s.gsub(/^[ ]*|[ ]*$/, ""), :var]
		else
			warn "Rotor: Uncategorized Syntax"
			warn s
			warn "^" * s.size
			rt = nil
		end
	end
	def bulk_typeof?(a)
		az = a.dup
		az.each do |o|
			az[az.index(o)] = Rotor.typeof?(o)
		end
		puts "BulkTypeOf:\tBefore:\t#{a.inspect}" if self.DEBUG
		puts "BulkTypeOf:\tAfter:\t#{az.inspect}" if self.DEBUG
		return az
	end
end

class Rotor::RotoScript
	attr_accessor :byc
	def initialize(text)
		lns = text.split(/(\r)?\n/)
		cc = []
		func = nil
		for l in lns
			next if l =~ /^[ ]*$/
			next if l.split(" ") == []
			co = [l.split(" ")[0], Rotor.bulk_typeof?(specoin(l.split(" ")[1..-1].join(" ").split(/,/)))]
			cc << co
		end
		@byc = cc
	end
	
	private
	
	def specoin(arr)
		a = arr.dup
		a = joins(a, /^[ ]*("|')/, /("|')[ ]*$/)
		a = joins(a, /^[ ]*\[/, /\][ ]*$/)
		a = joins(a, /^[ ]*\{/, /\}[ ]*$/)
		puts "SpeCOIN:\t#{a.inspect}" if Rotor.DEBUG
		a
	end
	def joins(a, sreg=/^"/, ereg=/"$/)
		a = a.dup
		inst = false
		a.each do |pt|
			inst = a.index(pt) if (pt =~ sreg) and not (inst)
			if (pt =~ ereg) and (inst)
				rng = inst..(a.index(pt))
				a[rng] = a[rng].join(",")
				inst = false
			end
		end
		return a
	end
end

