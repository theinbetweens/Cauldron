#module Cauldron::Operator

  class ToSOperator

    def intialize
    end

    def build(operators)
      # [:method_add_block, 
      #   [:call, 
      #     [:vcall, 
      #       [:@ident, "var0"]], 
      #       :".", 
      #       [:@ident, "collect"]
      #   ], 
      #   [:brace_block, 
      #     [:block_var, 
      #       [:params, [[:@ident, "x"]]]], 
      #       [:stmts_add, [:stmts_new], operators.first.build('x')
      #     ]
      #   ]
      # ]    
    end

  end

#end