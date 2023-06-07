from header    import create_header
from functions import fn_main, fn_loop

from llvmlite import binding as llvm
from llvmlite import ir

from ctypes import CFUNCTYPE

def create_module():
    # llvm module
    module = ir.Module('llvm-py')

    # create header
    msg, loop_msg, puts = create_header(module)

    # loop function
    loop_fn = fn_loop(module, loop_msg, puts)

    # main function
    fn_main(module, msg, puts, loop_fn)

    # return module
    return module

def compile_module(module):
    # initialize parts
    llvm.initialize()
    llvm.initialize_native_target()
    llvm.initialize_native_asmprinter()

    # parse assembly into module
    llvm_mod = llvm.parse_assembly(str(module))

    # create target machine
    target = llvm.Target.from_default_triple().create_target_machine()

    # create mcjit compiler
    mcjit = llvm.create_mcjit_compiler(llvm_mod, target)

    # finalize object
    mcjit.finalize_object()

    # get main function
    fn_ptr  = mcjit.get_function_address('main')
    llvm_fn = CFUNCTYPE(None)(fn_ptr)

    # run llvm function
    llvm_fn()
