Feature: Cauldron generates single parameter methods

	Cauldron can generate runtime methods that accepts one parameters
	
	NOTE: it creates the file in tmp/aruba/launch.rb - so that loading path needs to be changed
				- use @pause to see if it's working.

 	@announce @slow_process @new_approach
	Scenario: Method returns the passed in value
    Given a theory named "example_1.yml" with:
      """
        dependents:
          RUNTIME_METHOD.kind_of?(RuntimeMethod)
          ARG_1 == OUTPUT
        action:
          statement: "return x"
          values
            x: ARG_1
          position: RUNTIME_METHOD.first.statement_id
        results:
          COMPLETE
      """	
  	And a file named "launch.rb" with:
      """
			$LOAD_PATH.unshift File.expand_path( File.join('lib') )
			require 'cauldron'
			cauldron = Cauldron::Terminal.new(STDOUT,false)
			cauldron.start
      """		
		And I run `ruby launch.rb` interactively
    And I add the case "sparky","sparky"
    And I type "RUN"
    When I type "QUIT"
    Then the output should contain:
      """
      def method_0(var_0)
        return var_0
      end
      """
  
  # @announce @slow_process
  # Scenario: Generates solution to demo 2
    # Given a file named "launch.rb" with:
      # """
      # $LOAD_PATH.unshift File.expand_path( File.join('lib') )
      # require 'cauldron'
      # cauldron = Cauldron::Terminal.new(STDOUT,false)
      # cauldron.start
      # """   
    # And I run `ruby launch.rb` interactively
    # And I add the case "carrot","vegtable"
    # And I add the case "apple","fruit"
    # And I type "RUN"
    # When I type "QUIT"
    # Then the output should contain:
      # """
      # return var_0
      # """    
    # And the output should contain:
      # """
      # if var_0
      # """    		
