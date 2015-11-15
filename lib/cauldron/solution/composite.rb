module Cauldron::Solution

  class Composite

    attr_reader :operators

    def initialize(*operators)
      @operators = operators
    end

    def sexp(variables=[])
      # [ 
      #   :1, [],
      #   :2, [],
      # ]
      #args = problem[:arguments]
      #variables = (0...args.length).collect {|x| 'var'+x.to_s}
      results = operators.collect do |x|
        x[0].build(x[1...x.length], variables)
      end
      # TODO Not sure why this is needed just yet
      [:program, *results]
    end

    def to_ruby(variables)
      Sorcerer.source(sexp(variables))
    end

    def successful?(problem)

      # # TODO track the parameters of the operator
      # operators.trace(problem)

      # # TODO For now just evalute the code
      # return true if problem[:arguments].first == problem[:response]    
      # false    
      pt = PryTester.new
      #pt.eval([self.to_ruby])

      args = problem[:arguments]
      variables = (0...args.length).collect {|x| 'var'+x.to_s}

      # result = [
      #   'def function('+variables.join(',')+')',
      #   self.to_ruby,
      #   'end'
      # ]


      #pt.eval(result)
      #pt.eval(['def function('+variables.join(',')+');'+self.to_ruby+"; end"])
      
      # 'def function('+variables.join(',')+');'+self.to_ruby+"; end", 'function('+problem[:arguments][0].to_s+')'
      # "def function('+variables.join(',')+');'+self.to_ruby+"; end", 'function('+problem[:arguments][0].to_s+')'
      a = [
        'def function('+variables.join(',')+');'+self.to_ruby(variables)+"; end", 
        'function('+problem[:arguments].collect {|x| to_programme(x) }.join(',')+')'
      ]
      puts 'def function('+variables.join(',')+');'+self.to_ruby(variables)+"; end", 'function('+problem[:arguments].collect {|x| to_programme(x) }.join(',')+')'
      
      res = pt.eval(
        ['def function('+variables.join(',')+');'+self.to_ruby(variables)+"; end", 'function('+problem[:arguments].collect {|x| to_programme(x) }.join(',')+')']
      )

      #problem[:response] == Pry::Code.new(self.to_ruby)
      problem[:response] == res
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