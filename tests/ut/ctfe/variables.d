module ut.ctfe.variables;


import ut.ctfe;


@("variables")
@safe pure unittest {
    enum mod = module_!("modules.variables");
    mod.variables.shouldBeSameSetAs(
        [
            Variable("int", "gInt"),
            Variable("double", "gDouble"),
            Variable("Struct", "gStruct"),
            Variable("int", "CONSTANT"),
        ]
    );
}
