module Cauldron

	class Function

		PLACE_HOLDER_COPY = "'#CODE_HERE#'"

		def initialize
			@content = %Q{
      		def extend_function_test_method(var1)
				'#CODE_HERE#'
      		end
      		}
		end

		def apply_theory(theory)
			@content.gsub!("'#CODE_HERE#'",theory.insert_statement)
			self
		end

		def write
			content = @content.gsub("'#CODE_HERE#'",'')
			parser    = RubyParser.new
			ruby2ruby = Ruby2Ruby.new  
			#sexp      = parser.process(@content)         		
			sexp      = parser.process(content)         		
			ruby2ruby.process(sexp)			
		end

	end

end