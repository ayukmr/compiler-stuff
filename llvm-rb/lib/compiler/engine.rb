module Compiler
  # compiler engine
  module Engine
    class << self
      # compile module
      def compile(mod, fn_main)
        # initialize jit
        LLVM.init_jit

        # compile ir
        engine = LLVM::JITCompiler.new(mod)
        engine.run_function(fn_main)
        engine.dispose
      end
    end
  end
end
