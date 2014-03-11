
class NumericValueRelationship < Relationship

  def initialize(problems)
    @problems = problems
  end

  def to_ruby  
    ''
  end

  def self.match?(problem)
    return false unless problem.collect {|x| x[:arguments] }.flatten.all? {|x| x.kind_of?(Numeric)} 
    return false unless problem.collect {|x| x[:response] }.all? {|x| x.kind_of?(Numeric)} 
    problem.collect {|x| x[:response] - x[:arguments].first }.uniq.length == 1
  end

end