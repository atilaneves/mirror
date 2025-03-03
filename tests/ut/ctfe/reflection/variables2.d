module ut.ctfe.reflection.variables2;


import ut.ctfe.reflection;


@("variables")
@safe pure unittest {
    enum mod = module_!("modules.variables");
    mod.variables[].shouldBeSameSetAs(
        [
            Variable(Type("int"), "modules.variables.gInt"),
            Variable(Type("immutable(double)"), "modules.variables.gDouble"),
            Variable(Type("modules.variables.Struct"), "modules.variables.gStruct"),
            Variable(Type("int"), "modules.variables.CONSTANT_INT"),
            Variable(Type("string"), "modules.variables.CONSTANT_STRING"),
            Variable(Type("immutable(int)"), "modules.variables.gImmutableInt"),
        ]
    );
}
