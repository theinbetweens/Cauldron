require 'spec_helper'

module Cauldron
  
  describe 'Pot' do 
    
    describe '#load_theory' do
      
      it 'should be able to load theory' do
        pot = Pot.new
        pot.load_theory(File.join('theories','example_1.yml')).should == true
      end
      
      it "should raise an exception if the theory is missing" do
        pot = Pot.new
        lambda {pot.load_theory('not_there.yml')}.should raise_exception(Errno::ENOENT)
      end
      
    end
    
    describe '#generate' do
      
      it 'should return a runtime method' do
        pot = Pot.new
        pot.load_theory(File.join('theories','example_1.yml'))
        pot.generate(["sparky","sparky"]).should == 
"""
def extend_function_test_method(var1)
  return var1
end                  
""".strip
      end

      context 'passed two cases' do

        it 'should generate a valid runtime method' do
          pot = Pot.new
          pot.load_theory(File.join('theories','example_1.yml'))
          pot.generate([["sparky","sparky"],["kel","kel"]]).should == 
"""
def extend_function_test_method(var1)
  return var1
end                  
""".strip          
        end

      end
      
      it "shouldn't generate a method if hasn't any theories loaded" do
        pot = Pot.new
        pot.generate([["sparky","sparky"],['kel','kel']]).should == "There aren't any theories loaded so Cauldron is unable to generate a solution"
      end
      
      
    end
    
  end
  
end