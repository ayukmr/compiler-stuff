use inkwell::{
    AddressSpace,
    context::Context,
    module::Linkage,
    types::{BasicMetadataTypeEnum as MetadataType, IntType},
    values::BasicMetadataValueEnum as MetadataValue,
};

fn main() {
    // llvm context
    let context = Context::create();
    let module  = context.create_module("llvm-rs");
    let builder = context.create_builder();

    // int types
    let i8_type  = context.i8_type();
    let i32_type = context.i32_type();

    // [12 x i8] c"hello world\00"
    let text  = "hello world\0";
    let array = i8_type.array_type(text.len() as u32);
    let msg   = module.add_global(array, Some(AddressSpace::Generic), "msg");

    let chars = text.bytes()
        .map(|chr| i8_type.const_int(chr as u64, false))
        .collect::<Vec<_>>();

    let text_const = i8_type.const_array(chars.as_slice());

    // @.msg = global ...
    msg.set_initializer(&text_const);

    // declare i32 @puts(i8* ...)
    let puts_type = IntType::fn_type(
        i32_type,
        &[MetadataType::PointerType(
            i8_type.ptr_type(AddressSpace::Generic)
        )],
        true
    );

    let puts = module.add_function("puts", puts_type, Some(Linkage::External));

    // define i32 @main() { ... }
    let fn_type = IntType::fn_type(i32_type, &[], false);
    let func    = module.add_function("main", fn_type, None);

    // entry: ...
    let block = context.append_basic_block(func, "entry");
    builder.position_at_end(block);

    // call i32 @puts(i8* ...)
    unsafe {
        let pointer = builder.build_gep(
            msg.as_pointer_value(),
            &[i8_type.const_int(0, false), i8_type.const_int(0, false)],
            ""
        );

        builder.build_call(puts, &[MetadataValue::PointerValue(pointer)], "");
        builder.build_return(Some(&i32_type.const_int(0, false)));
    }

    // print module
    println!("{}", module.to_string());
}
