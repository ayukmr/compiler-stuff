module Compiler
  # llvm header
  module Header
    class << self
      # create header
      def create(mod)
        # %.msg = private unnamed_addr constant [13 x i8] c"hello world\00"
        text = 'hello world'
        msg = mod.globals.add(LLVM::ConstantArray.string(text), :msg) do |var|
          var.linkage         = :private
          var.global_constant = true
          var.unnamed_addr    = true
          var.initializer     = LLVM::ConstantArray.string(text)
        end

        # %.loop_msg = private unnamed_addr constant [13 x i8] c"loop\00"
        text = 'loop'
        loop_msg = mod.globals.add(LLVM::ConstantArray.string(text), :loop_msg) do |var|
          var.linkage         = :private
          var.global_constant = true
          var.unnamed_addr    = true
          var.initializer     = LLVM::ConstantArray.string(text)
        end

        # declare i32 @puts(i8* ...)
        fn_puts = mod.functions.add('puts', [LLVM::Pointer(LLVM::Int8)], LLVM::Int32)

        [msg, loop_msg, fn_puts]
      end
    end
  end
end
