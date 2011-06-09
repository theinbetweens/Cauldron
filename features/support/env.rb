$LOAD_PATH << File.expand_path('../../../lib',__FILE__)

require 'cauldron'

class Output
  
  def messages
    @messages ||= []
  end
  
  def puts(message)
    messages << message
  end
  
end

def output
  @output ||= Output.new
end