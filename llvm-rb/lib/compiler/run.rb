module Compiler
  # run compiler
  module Run
    class << self
      # run compiler
      def run
        # create module and header
        mod = Compiler::Module.create
        msg, loop_msg, fn_puts = Compiler::Header.create(mod)

        # create functions
        fn_loop = Compiler::Functions.fn_loop(mod, loop_msg, fn_puts)
        fn_main = Compiler::Functions.fn_main(mod, msg, fn_puts, fn_loop)

        # compile module
        Compiler::Engine.compile(mod, fn_main)
      end
    end
  end
end
