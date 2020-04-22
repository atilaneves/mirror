module ut.ctfe.reflection.variables;


import ut.ctfe.reflection;


@("variables")
@safe pure unittest {
    enum mod = module_!("modules.variables");
    mod.variables[].shouldBeSameSetAs(
        [
            Variable("int", "gInt"),
            Variable("immutable(double)", "gDouble"),
            Variable("modules.variables.Struct", "gStruct"),
            Variable("int", "CONSTANT_INT"),
            Variable("string", "CONSTANT_STRING"),
            Variable("immutable(int)", "gImmutableInt"),
        ]
    );
}
