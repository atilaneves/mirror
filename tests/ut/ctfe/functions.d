module ut.ctfe.functions;


import ut.ctfe;


@("foo")
@safe pure unittest {
    enum mod = module_!("modules.functions");
    mod.functions.shouldBeSameSetAs(
        [
            Function("add1", "int", [Parameter("int", "i"), Parameter("int", "j")]),
        ]
    );
}
