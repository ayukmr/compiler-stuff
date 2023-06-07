from llvmlite import ir

# int types
i8  = ir.IntType(8)
i32 = ir.IntType(32)

# misc types
arr = ir.ArrayType
ptr = ir.PointerType

def create_header(module):
    # constant [13 x i8] c"hello world\00"
    text = 'hello world\0'
    text_const = ir.Constant(arr(i8, len(text)), bytearray(text.encode('utf-8')))

    # @.msg = internal ...
    msg = ir.GlobalVariable(module, text_const.type, '.msg')
    msg.linkage = 'internal'
    msg.global_constant = True
    msg.initializer = text_const

    # constant [5 x i8] c"loop\00"
    text = 'loop\0'
    text_const = ir.Constant(arr(i8, len(text)), bytearray(text.encode('utf-8')))

    # @.loop_msg = internal ...
    loop_msg = ir.GlobalVariable(module, text_const.type, '.loop_msg')
    loop_msg.linkage = 'internal'
    loop_msg.global_constant = True
    loop_msg.initializer = text_const

    # declare i32 @puts(i8* ...)
    puts_type = ir.FunctionType(i32, [ptr(i8)])
    puts = ir.Function(module, puts_type, 'puts')

    return msg, loop_msg, puts
