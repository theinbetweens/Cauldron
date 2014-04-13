#http://www.ruby-doc.org/core-2.1.1/Hash.html
#hsh[key] → value
class HashKeyValueOperator

  def initialize(constant)
    @constant = constant
  end

  def self.viable?(arguments, response)
    return false unless arguments.all? { |x| x.kind_of?(Hash) }
    true
  end

  def self.uses_constants?
    true
  end

  def self.find_constants(problems)
    problems.collect {|x| x[:arguments].first.keys }.flatten
  end

  def successful?(problem)
    if problem[:arguments].first[@constant] == problem[:response]
      return true
    end
    return false    
  end

  def to_ruby
    if @constant.kind_of?(Symbol)
      return %Q{  var0[:#{@constant}]}+"\n"
    end
    %Q{  var0['#{@constant}']}+"\n"
  end

end