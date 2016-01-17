module Cauldron::Solution

  class Composite

    attr_reader :operators

    def initialize(children)
      @operators = children
    end

    def record(example)
      # TODO params passed twice - and example not used at all
      insert_tracking(example.params).process(example)
    end

    def insert_tracking(params)
      scope = Cauldron::Scope.new(params)

      # TODO Might be useful
      # trace = TracePoint.new(:call) do |tp|
      #   p [tp.lineno, tp.event, tp.raised_exception]
      # end

      
      # NEW: Implementation
      m = %Q{
        def function(#{params.join(',')})
          #{to_ruby(Cauldron::Scope.new(params))}
        end
      }
      sexp = Ripper::SexpBuilder.new(m).parse
      rendered_code = Sorcerer.source(sexp, indent: true)

      caret = Cauldron::Caret.new

      tracked_code = []
      rendered_code.each_line do |line|
        if line.match /end\s+/
          tracked_code << Sorcerer.source(Cauldron::Tracer.tracking(caret.line, caret.current_depth, caret.total_lines))
        end
        tracked_code << line
      end

      #puts tracked_code.join("\n")
      
      sexp = Ripper::SexpBuilder.new(tracked_code.join("\n")).parse 
      #puts Sorcerer.source(sexp, indent: true)   
      
      Cauldron::Tracer.new(sexp)
      # =================================


      #puts Sorcerer.source(sexp, indent: true)
      #to_ruby(Cauldron::Scope.new(params))
      # o = Object.new
      # m = %Q{
      #   def function(#{params.join(',')})
      #     #{to_ruby(Cauldron::Scope.new(params))}
      #   end
      # }
      # o.instance_eval(m)
      #

#       sexp = Ripper::SexpBuilder.new(
# %Q{
# def function(#{params.join(',')})
#   #{Sorcerer.source(tracking_sexp(scope, Cauldron::Caret.new )) }
# end
# }).parse
#       Cauldron::Tracer.new(sexp)
    end

    def tracking_sexp(scope, caret)
      if operators.empty?
        sexp = [:bodystmt,
          [:stmts_add,
            [:stmts_new]
          ],
          Cauldron::Tracer.tracking(caret.line, caret.current_depth, caret.total_lines)
        ]        
      else

        if operators.length == 1
          inner = operators.first.content.to_tracking_sexp(
                    operators.first.children, scope, caret
                  ) 
          sibling = reset_and_track(caret)
          sexp = [
                  :bodystmt,
                    [:stmts_add, 
                      [:stmts_add,
                        [:stmts_new],
                        inner
                      ],
                      sibling
                    ]
                  ]
        else
          raise StandardError.new('Currently only supporting 1')
        end
      end
      sexp
    end

    def reset_and_track(caret)
      caret.return_depth(0)
      Cauldron::Tracer.tracking(caret.line, caret.current_depth, caret.total_lines)
    end

    def to_sexp(variables=[])

      #return [] if operators.empty?

      first = operators.first
      
      #inner = add_first_statement( first.content.build(first.children.first, variables) )
      inner = add_first_statement( 
                first.content.build(
                  first.children, variables
                ) 
              )

      second = operators[1]
      
      if second.nil?
        results = inner
      else
        results = add_statement(
                    second.content.build(second.children, variables),
                    inner
                  )
      end
      
      # TODO Not sure why this is needed just yet
      [:program, results]
    end

    def to_ruby(scope)
      return '' if operators.empty?
      Sorcerer.source(to_sexp(scope))
    end

    def add_first_statement(statement)
      [:stmts_add, [:stmts_new], statement]
    end

    def add_statement(statement, inner)
      [:stmts_add, inner, statement]
    end

    def solution?(problems)
      o = Object.new
      m = %Q{
        def function(#{problems.variables.join(',')})
          #{to_ruby(problems.scope)}
        end
      }
      o.instance_eval(m)

      #o.function *problems.examples.first.arguments
      puts '------ :: ------'
      puts "#{problems.variables.join(',')}"
      puts self.class
      puts "#{to_ruby(problems.scope)}"
      problems.all? do |example|
        o.function(*example.arguments) == example.response
      end

    end

    # TODO Drop this method
    def successful?(problem)

      # # TODO track the parameters of the operator
      # operators.trace(problem)

      # # TODO For now just evalute the code
      # return true if problem[:arguments].first == problem[:response]    
      # false

      pt = PryTester.new

      args = problem.arguments
      variables = problem.params #(0...args.length).collect {|x| 'var'+x.to_s}
      a = [
        'def function('+variables.join(',')+');'+self.to_ruby(variables)+"; end", 
        'function('+problem.arguments.collect {|x| to_programme(x) }.join(',')+')'
      ]
      
      res = pt.eval(
        ['def function('+variables.join(',')+');'+self.to_ruby(variables)+"; end", 'function('+problem.arguments.collect {|x| to_programme(x) }.join(',')+')']
      )

      problem.response == res
    end

    def to_programme(value)
      if value.kind_of?(String)
        return %Q{'#{value}'}
      end
      value.to_s
    end

    # TODO Add a safety evalutor
    
  end

end