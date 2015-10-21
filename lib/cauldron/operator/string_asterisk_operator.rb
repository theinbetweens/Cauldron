class StringAsteriskOperator

  # var0 * 3

  # TODO Possibly include the scope of the index
  # a = 5
  # ['sdsd'].each do |b|
  #   c = 5
  # end
  # (1...6).each do |d|
  #   g = d
  # end

  # [0] = ['a']
  # [1] = ['b', 'c']
  # [2] = ['g', 'd']

  # Although it should probably be
  # [0] = [ ['a'] ]
  # [1] = [ ['b', 'c'], ['g', 'd'] ]
  #
  # Or the order it was added might be more useful - e.g. last variable, second last variable or first variable
  # - variable at depth(1)[1] - stepUp(1).first
  def initialize(indexes, constant)
    @constant, @indexes = constant, indexes
  end

  def self.find_constants(problems)
    problems.collect {|x| x[:response].scan(x[:arguments].first).count }.reject {|x| x == 0}
  end

  def self.viable?(arguments,output)
    return false unless output.kind_of?(String)
    return false unless arguments.first.kind_of?(String)
    true
  end

  def self.uses_constants?
    true
  end

  def self.uses_block?
    false
  end  

  def successful?(problem)
    return true if problem[:arguments].first*@constant == problem[:response]    
    false
  end

  def to_ruby(variables)
    Sorcerer.source self.to_sexp(variables)
  end

  def to_sexp(variables)
    [:binary, [:vcall, [:@ident, variables[@indexes[0]] ]], :*, [:@int, @constant]]
  end

  # TODO Get rid of the defined names
  def build(nested, variables)
    #[:binary, [:vcall, [:@ident, variables[@indexes[0]] ]], :*, [:@int, @constant]]
    to_sexp(variables)
  end

end