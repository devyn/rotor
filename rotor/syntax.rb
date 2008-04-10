
require 'syntax' unless defined?(Syntax)
require 'syntax/convertors/html' unless defined?(Syntax::Convertors::HTML)
require 'rotor/all' unless defined?(Rotor)

class Syntax::Rotor < Syntax::Tokenizer
	def step
		if commands = scan(/#{(%w(method extern command import globals call(on|var|)? set get new valueof add subt div ti exp equ out nout quit) + Rotor::Interpreter::COMMANDS.keys).join("|")}/)
			start_group :commands, commands
		elsif comments = scan(/comment\ .*/)
			start_group :comments, comments
		elsif integers = scan(/\d+/)
			start_group :integers, integers
		elsif pointers = scan(/[A-Za-z0-9_]+(\.[A-Za-z0-9_]+)+|[A-Za-z0-9_]+(\.[A-Za-z0-9_]+)*(->[a-z][A-Za-z0-9_]*[\!\?]?)+/)
			start_group :pointers, pointers
		elsif strings = scan(/"[^"]*"|'[^']*'/)
			start_group :strings, strings
		elsif chars = scan(/\?./)
			start_group :chars, chars
		elsif symbols = scan(/:[^ :]*/)
			start_group :symbols, symbols
		elsif opers = scan(/[\[\]\{\}]/)
			start_group :opers, opers
		else
			start_group :other, scan(/.|\n/)
		end
	end
end

Syntax::SYNTAX['rotor'] = Syntax::Rotor

module Rotor
	
	CSS = %[<style>
			
			.rotor .commands { color: green; font-weight: bold; }
			.rotor .comments { color: grey; font-style: italic; }
			.rotor .integers { color: blue; font-weight: bold;  }
			.rotor .pointers { color: red;                      }
			.rotor .strings  { color: brown;                    }
			.rotor .chars    { color: cyan;                     }
			.rotor .symbols  { color: darkyellow;               }
			
		</style>
]
	
	def format(code)
		return Rotor::CSS + "<pre class='rotor'>" + Syntax::Convertors::HTML.for_syntax("rotor").convert(code, false) + "</pre>"
	end
end
