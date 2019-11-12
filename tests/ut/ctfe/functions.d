module ut.ctfe.functions;


import ut.ctfe;


@ShouldFail("Not caught up with meta implementation wrt overloads yet")
@("functions")
@safe pure unittest {
    import std.traits: PSC = ParameterStorageClass;

    enum mod = module_!("modules.functions");
    mod.functions[].shouldBeSameSetAs(
        [
            Function(
                "add1",
                Type("int"),
                [
                    Parameter("int", "i"),
                    Parameter("int", "j"),
                ],
            ),
            Function(
                "add1",
                Type("double"),
                [
                    Parameter("double", "d0"),
                    Parameter("double", "d1"),
                ],
            ),
            Function(
                "withDefault",
                Type("double"),
                [
                    Parameter("double", "d0"),
                    Parameter("double", "d1", "33.3"),
                ],
            ),
            Function(
                "storageClasses",
                Type("void"),
                [
                    Parameter("int", "normal", "", PSC.none),
                    Parameter("int*", "returnScope", "", PSC.return_ | PSC.scope_),
                    Parameter("int", "out_", "", PSC.out_),
                    Parameter("int", "ref_", "", PSC.ref_),
                    Parameter("int", "lazy_", "", PSC.lazy_),
                ]
            ),
            Function(
                "exportedFunc",
                Type("void"),
                [],
            ),
            Function(
                "externC",
                Type("void"),
                [],
            ),
            Function(
                "externCpp",
                Type("void"),
                [],
            ),
            Function(
                "identityInt",
                Type("int"),
                [Parameter("int", "x", "", PSC.none)],
            ),
        ]
    );
}
