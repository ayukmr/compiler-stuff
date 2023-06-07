module Compiler
  # llvm functions
  module Functions
    class << self
      # main function
      def fn_main(mod, msg, fn_puts, fn_loop)
        # define i32 @main() { ... }
        mod.functions.add('main', [], LLVM::Int32) do |function|
          fn_main_bk(function, msg, fn_puts, fn_loop)
        end
      end

      # main function block
      def fn_main_bk(function, msg, fn_puts, fn_loop)
        # entry: ...
        function.basic_blocks.append.build do |builder|
          # call i32 @puts(i8* ...)
          zero = LLVM.Int(0)
          ptr  = builder.gep(msg, [zero, zero])
          builder.call(fn_puts, ptr)

          # call void loop(i32 5)
          builder.call(fn_loop, LLVM.Int(5))

          # ret i32 0
          builder.ret(zero)
        end
      end

      # loop function
      def fn_loop(mod, loop_msg, fn_puts)
        # define void @loop(i32 %n) { ... }
        mod.functions.add('loop', [LLVM::Int32], LLVM.Void) do |function, arg_n|
          fn_loop_bk(function, arg_n, loop_msg, fn_puts)
        end
      end

      # loop function block
      def fn_loop_bk(function, arg_n, loop_msg, fn_puts)
        # blocks
        bk_entry = function.basic_blocks.append('entry')
        bk_body  = function.basic_blocks.append('body')
        bk_latch = function.basic_blocks.append('latch')
        bk_exit  = function.basic_blocks.append('exit')

        # variables
        i = nil
        i_next = nil

        # entry: ...
        bk_entry.build do |builder|
          # %i.next = i32 0
          i_next = builder.alloca(LLVM::Int32)
          builder.store(LLVM.Int(0), i_next)

          # br label %body
          builder.br(bk_body)
        end

        # body: ...
        bk_body.build do |builder|
          # %i = %i.next
          i = builder.alloca(LLVM::Int32)
          builder.store(builder.load(i_next), i)

          # br label %latch
          builder.br(bk_latch)
        end

        # latch: ...
        bk_latch.build do |builder|
          # %i.next = add i32 %i, 1
          i_new = builder.add(builder.load(i), LLVM.Int(1))
          builder.store(i_new, i_next)

          # call i32 @puts(i8* ...)
          zero = LLVM.Int(0)
          ptr  = builder.gep(loop_msg, [zero, zero])
          builder.call(fn_puts, ptr)

          # %cond = icmp slt i32 %i.next, %n
          cond = builder.alloca(LLVM::Int1)
          cmp  = builder.icmp(:slt, builder.load(i_next), arg_n)
          builder.store(cmp, cond)

          # br i1 %cond, label %body, label %exit
          builder.cond(builder.load(cond), bk_body, bk_exit)
        end

        # exit: ret void
        bk_exit.build(&:ret_void)
      end
    end
  end
end
