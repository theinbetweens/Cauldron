# => TODO This is a duplicate of of UnifiedChain - it needs stripped down allot - probably shouldn't exist

class PartialChain
  
  def initialize(nodes)
    @nodes = nodes
  end
  
  def write(tab=0)
    return @nodes.inject('') {|total,x| total += x.write}
  end
  
  def describe(tab=0)
    return @nodes.inject('') {|total,x| total += x.describe}
  end
  
  def copy
    #return Chain.new(@nodes.copy)
    return Marshal.load(Marshal.dump(self))
  end  
  
  # Returns an array of all the theory variables in the chain.  All the 
  # theory variables should be global across the chain. 
  #
  def theory_variables
    results = @nodes.inject([]) do |total,theory|
      total += theory.all_theory_variables.collect {|x| x}
      total
    end
    return results.uniq
  end
  
  def length
    return @nodes.length
  end
  
  # Return an implemented version of the chain where all the theory variables have
  # been replaced with read values.
  #
  def implement(mapping)
    implemented_nodes = @nodes.inject([]) do |total,theory|
      total << theory.map_to(mapping)
    end
    return ImplementedChain.new(implemented_nodes,mapping)
  end

  def implementation_permuatations2(runtime_method,test_cases,mapping)

    more_mapping = valid_mapping_permutations(runtime_method.copy,test_cases.copy)

    return more_mapping.inject([]) { |total,mapping| total << self.copy.implement(mapping) }
    
  end
  
  def has_all_variables_been_found?(component,mappings)
    component.theory_variables.each do |var|
      mappings.each do |mapping|
        return false unless mapping.has_key? var.theory_variable_id
      end
    end
    return true
  end
  
  def identify_uniq_mappings(mappings)
    uniq_mappings = []
    count = mappings.length
    until mappings.empty?
      mapping = mappings.shift
      already_exists = mappings.any? do |x|
        next false unless x.length == mapping.length
        next false unless x.keys.sort == mapping.keys.sort
        all_values_the_same = true 
        x.each do |key,value|
          if mapping[key].class != value.class
            all_values_the_same = false
          end 
          if mapping[key].class == value.class
            if mapping[key].kind_of?(IntrinsicLiteral)
              if mapping[key].write != value.write
                all_values_the_same = false
              end
            end
          end
        end
        next false unless all_values_the_same
        next true
      end
      unless already_exists
        uniq_mappings << mapping
      end
    end
    if uniq_mappings.length == 0 && count != 0
      raise StandardError.new('uniq_mappings should not be 0')
    end
    return uniq_mappings
  end
  
  def intrinsic_values_for_variable(id,component,mapping,runtime_method,test_cases,intrinsic_values)
    
    values = []
    component.statements_with_variable(id).each do |statement|
      reg = eval('/^var'+id.to_s+'\./')
        if statement.write.match(reg)
        
        intrinsic_values.each do |value|
          temp_mapping = mapping.copy
          temp_mapping[id] = value
          # => TODO Not validating the component - e.g. if(var1.kind_of?(RuntimeMethod))
          if valid_mapping?(runtime_method.copy,test_cases.copy,statement,temp_mapping)
            values << value
          end
        end
        next
      end
      
      # values for index
      index_values = []
      intrinsic_statement = statement.map_to(mapping)
      if intrinsic_statement.select_all {|z| z.kind_of?(TheoryVariable)}.length > 0
        if m = intrinsic_statement.write.match(/([\w\.]+)\[var(\d)+\]/)
          method_call = $1
          if m2 = method_call.match(/var(\d+)/)
            next 
          end
          literal = evaluate_statement(method_call,runtime_method.copy,test_cases.copy)
          literal.length.times do |n|
            index_values << IntrinsicLiteral.new(n)
          end        
        end    
      end      
      values += index_values
      
      #variable_values = []
      #result.statements_with_variable(var.theory_variable_id).each do |statement|
      #variable_values += values_for_variable_as_argument(var,statement,mapping,intrinsic_values,implemented_runtime_method.copy,test_cases.copy)
      #end
      #values += variable_values
      
      #intrinsic_statement = statement.map_to(mapping)
      variable_values = []
      intrinsic_values.each do |value|
        literal = intrinsic_statement.write.gsub(/var(\d)+/,value.write)
        begin
          eval literal
          variable_values << value
        rescue
          next
        end
      end
      #return results
      values += variable_values      
      
      
    end
    return values
  end
  
  def mapping_permutations(keys,values)
    values.permutation(keys.length).to_a.inject([]) do |total,value_permutation|
      total << Hash[*keys.zip(value_permutation).flatten]
    end
  end
  
  def valid_mapping?(runtime_method,test_cases,statement,mapping)
    intrinsic_statement = statement.map_to(mapping)
    return false unless intrinsic_statement.select_all {|z| z.kind_of?(TheoryVariable)}.length == 0
    valid_statement?(intrinsic_statement,runtime_method.copy,test_cases.copy)
  end
  
  def evaluate_statement(statement,runtime_method,test_cases)
    eval statement
  end
  
  def valid_statement?(statement,runtime_method,test_cases)
    eval statement.write
    return true
  rescue NoMethodError
    return false    
  end
  
  # Returns an array of implemented chains using the various value
  # permutations.  Essential what it is looking for is mapping to convert 
  # all the theory variables to intrinsic variables.
  #
  # @param  runtime_method    The runtime method instance that will be populated to 
  #                           create the solution.<#RuntimeMethod >
  # @param  test_cases        The test cases instance containing real values.
  #
  def implementation_permuatations(runtime_method,test_cases,mapping)
    
    return implementation_permuatations2(runtime_method,test_cases,mapping)
    
    # Determine the number of variables without intrinsic values
    theory_variable_ids = theory_variables.collect {|x| x.theory_variable_id}
    
    # Collect the theory variables without intrinsic values
    missing_intrinsic_values = theory_variable_ids-mapping.keys
    
    # Take the first theory and identify all the accessors
    # (need to work out what is the runtime method and what the test cases)
    
    # TEMP: Why are these implemented theories
    # @nodes.first.all_theory_variables
    
    # Create the theory generator
    generator = TheoryGenerator.new()
    
    #accessors, temp_mapping = generator.generate_accessors_and_mapping(test_cases,runtime_method,1)
    accessors, temp_mapping = generator.generate_accessors_and_mapping(test_cases,runtime_method,3)

    if temp_mapping.length > missing_intrinsic_values.length

      # Now to assign real values to the chain
      
      # Apply the values in the various permutaions 
      # (this is very crude and means that odd calls )
      #theory_variable_ids = @nodes.first.all_theory_variables.collect {|x| x.theory_variable_id }
      
      theory_variable_ids = self.theory_variables.collect {|x| x.theory_variable_id }
      
      # Get the posible sets for values in an array so that non of the arrays contain all the same values
      res = temp_mapping.values.collect {|x| x}
      
      # TODO  This is a complete hack but I think I should be using intrinsic values rather than real
      intrinsic_res = res.collect {|x| x.to_intrinsic}
      value_permutaions = intrinsic_res.permutation(theory_variable_ids.length).to_a
      uniq_value_permutations = value_permutaions.collect {|x| x.to_set}.uniq
      possible_mappings = []
      
      theory_variable_id_permutations = theory_variable_ids.permutation(theory_variable_ids.length).to_a
      
      possible_mappings = []
      theory_variable_id_permutations.each do |theory_variable_id_permutation|
        uniq_value_permutations.each do |value_permutation|
          m = Mapping.new
          theory_variable_id_permutation.zip(value_permutation.to_a) do |key,value|
            m[key] = value
          end
          possible_mappings << m
        end
        
      end
      
      # Implemented changes
      return possible_mappings.inject([]) { |total,mapping| total << self.copy.implement(mapping) }
      
    else
      raise StandardError.new('Could not generate enough real vlaues to test theory - try increasing the itterations')
    end
    
  end      
  
end