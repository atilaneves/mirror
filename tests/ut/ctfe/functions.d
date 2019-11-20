module ut.ctfe.functions;


import ut.ctfe;


@("functions.byOverload")
@safe pure unittest {
    import std.traits: PSC = ParameterStorageClass;

    enum mod = module_!"modules.functions";
    mod.functionsByOverload[].shouldBeSameSetAs(
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
                    Parameter("double", "fst"),
                    Parameter("double", "snd", "33.3"),
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
            Function(
                "voldermort",
                Type("Voldermort"),
                [Parameter("int", "i", "", PSC.none)],
            ),
        ]
    );
}


@("functions.bySymbol")
@safe pure unittest {
    import std.traits: PSC = ParameterStorageClass;

    enum mod = module_!"modules.functions";
    mod.functionsBySymbol[].shouldBeSameSetAs(
        [
            FunctionSymbol(
                "add1",
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
                ]
            ),
            FunctionSymbol(
                "withDefault",
                [
                    Function(
                        "withDefault",
                        Type("double"),
                        [
                            Parameter("double", "fst"),
                            Parameter("double", "snd", "33.3"),
                        ],
                    ),
                ]
            ),
            FunctionSymbol(
                "storageClasses",
                [
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
                ]
            ),
            FunctionSymbol(
                "exportedFunc",
                [
                    Function(
                        "exportedFunc",
                        Type("void"),
                        [],
                    ),
                ]
            ),
            FunctionSymbol(
                "externC",
                [
                    Function(
                        "externC",
                        Type("void"),
                        [],
                        ),
                ]
            ),
            FunctionSymbol(
                "externCpp",
                [
                    Function(
                        "externCpp",
                        Type("void"),
                        [],
                        ),
                ]
            ),
            FunctionSymbol(
                "identityInt",
                [
                    Function(
                        "identityInt",
                        Type("int"),
                        [Parameter("int", "x", "", PSC.none)],
                    ),
                ]
            ),
            FunctionSymbol(
                "voldermort",
                [
                    Function(
                        "voldermort",
                        Type("Voldermort"),
                        [Parameter("int", "i", "", PSC.none)],
                    ),
                ]
            ),
        ]
    );
}


@("functions.allAggregates")
@safe pure unittest {
    import std.traits: PSC = ParameterStorageClass;

    enum mod = module_!"modules.functions";
    mod.allAggregates[].shouldBeSameSetAs(
        [
            Aggregate("Voldermort", Aggregate.Kind.struct_),
        ]
    );
}
