class CodeEvaluation
  
  # TODO  I should cap the number of CodeEvaluation classes that can be created
  @@COUNT = 0
  
  # Generates a class and dumps the passed in code into the 
  # a runtime method within the class and then runs it.
  #
  # @param  code    Ruby code as a string
  # 
  def evaluate_code(code)  
    @@COUNT += 1
    
    # Create file to include the test method
    filepath = $LOC+File.join(['tmp',"runtime_code_evaluation_#{@@COUNT}.rb"])
    file = File.open(filepath,'w+')
    
    # Include the sytax for the statement in the file
    file << "class RuntimeCodeEvaluation#{@@COUNT}"+"\n"
    file << "\t"+'def check'+"\n"
    code.each_line do |l|
      file << "\t\t"+l+"\n"
    end
    file << "\t"+'end'+"\n"
    file << 'end'
    file.close
    
    # Load the newly created class and check the statement
    load filepath

    return eval("RuntimeCodeEvaluation#{@@COUNT}.new.check")      
    
  end
  
end