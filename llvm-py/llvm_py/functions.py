from llvmlite import ir

# int types
i1  = ir.IntType(1)
i8  = ir.IntType(8)
i32 = ir.IntType(32)

# misc types
void = ir.VoidType()

def fn_main(module, msg, puts, loop_fn):
    # define i32 @main() { ... }
    fn_type = ir.FunctionType(i32, [])
    func    = ir.Function(module, fn_type, 'main')

    # entry: ...
    block   = func.append_basic_block('entry')
    builder = ir.IRBuilder(block)

    # call i32 @puts(i8* ...)
    zero    = ir.Constant(i8, 0)
    pointer = builder.gep(msg, [zero, zero])
    builder.call(puts, [pointer])

    # call void @loop(i32 5)
    builder.call(loop_fn, [i32(5)])

    # ret i32 0
    builder.ret(i32(0))

def fn_loop(module, loop_msg, puts):
    # define void @loop(i32 %n) { ... }
    fn_type = ir.FunctionType(void, [i32])
    func    = ir.Function(module, fn_type, 'loop')
    n = func.args[0]

    # blocks
    entry = func.append_basic_block('entry')
    body  = func.append_basic_block('body')
    latch = func.append_basic_block('latch')
    exit  = func.append_basic_block('exit')

    # entry: ...
    builder = ir.IRBuilder(entry)

    # %i.next = i32 0
    i_next = builder.alloca(i32)
    builder.store(i32(0), i_next)

    # br label %body
    builder.branch(body)

    # body: ...
    builder = ir.IRBuilder(body)

    # %i = %i.next
    i = builder.alloca(i32)
    builder.store(builder.load(i_next), i)

    # br label %latch
    builder.branch(latch)

    # latch: ...
    builder = ir.IRBuilder(latch)

    # %i.next = add i32 %i, 1
    i_new = builder.add(builder.load(i), i32(1))
    builder.store(i_new, i_next)

    # call i32 @puts(i8* ...)
    zero    = ir.Constant(i8, 0)
    pointer = builder.gep(loop_msg, [zero, zero])
    builder.call(puts, [pointer])

    # %cond = icmp slt i32 %i.next, %n
    cond = builder.alloca(i1)
    cmp  = builder.icmp_signed('<', builder.load(i_next), n)
    builder.store(cmp, cond)

    # br i1 %cond, label %body, label %exit
    builder.cbranch(builder.load(cond), body, exit)

    # exit: ...
    builder = ir.IRBuilder(exit)
    builder.ret_void()

    return func
