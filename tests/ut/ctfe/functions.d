module ut.ctfe.functions;


import ut.ctfe;


@("functions.byOverload")
@safe pure unittest {
    static import modules.functions;
    import std.traits: PSC = ParameterStorageClass;

    enum mod = module_!"modules.functions";
    mod.functionsByOverload[].shouldBeSameSetAs(
        [
            Function(
                null,
                "add1",
                Type("int"),
                [
                    Parameter("int", "i"),
                    Parameter("int", "j"),
                ],
            ),
            Function(
                null,
                "add1",
                Type("double"),
                [
                    Parameter("double", "d0"),
                    Parameter("double", "d1"),
                ],
            ),
            Function(
                null,
                "withDefault",
                Type("double"),
                [
                    Parameter("double", "fst"),
                    Parameter("double", "snd", "33.3"),
                ],
            ),
            Function(
                null,
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
                null,
                "exportedFunc",
                Type("void"),
                [],
            ),
            Function(
                null,
                "externC",
                Type("void"),
                [],
            ),
            Function(
                null,
                "externCpp",
                Type("void"),
                [],
            ),
            Function(
                null,
                "identityInt",
                Type("int"),
                [Parameter("int", "x", "", PSC.none)],
            ),
            Function(
                null,
                "voldermort",
                Type("Voldermort"),
                [Parameter("int", "i", "", PSC.none)],
            ),
            Function(
                null,
                "voldermortArray",
                Type("DasVoldermort[]"),
                [Parameter("int", "i", "", PSC.none)],
            ),
        ]
    );
}


@("functions.bySymbol")
@safe pure unittest {
    static import modules.functions;
    import std.traits: PSC = ParameterStorageClass;

    enum mod = module_!"modules.functions";
    mod.functionsBySymbol[].shouldBeSameSetAs(
        [
            OverloadSet(
                "add1",
                [
                    Function(
                        null,
                        "add1",
                        Type("int"),
                        [
                            Parameter("int", "i"),
                            Parameter("int", "j"),
                        ],
                    ),
                    Function(
                        null,
                        "add1",
                        Type("double"),
                        [
                            Parameter("double", "d0"),
                            Parameter("double", "d1"),
                        ],
                    ),
                ]
            ),
            OverloadSet(
                "withDefault",
                [
                    Function(
                        null,
                        "withDefault",
                        Type("double"),
                        [
                            Parameter("double", "fst"),
                            Parameter("double", "snd", "33.3"),
                        ],
                    ),
                ]
            ),
            OverloadSet(
                "storageClasses",
                [
                    Function(
                        null,
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
            OverloadSet(
                "exportedFunc",
                [
                    Function(
                        null,
                        "exportedFunc",
                        Type("void"),
                        [],
                    ),
                ]
            ),
            OverloadSet(
                "externC",
                [
                    Function(
                        null,
                        "externC",
                        Type("void"),
                        [],
                        ),
                ]
            ),
            OverloadSet(
                "externCpp",
                [
                    Function(
                        null,
                        "externCpp",
                        Type("void"),
                        [],
                        ),
                ]
            ),
            OverloadSet(
                "identityInt",
                [
                    Function(
                        null,
                        "identityInt",
                        Type("int"),
                        [Parameter("int", "x", "", PSC.none)],
                    ),
                ]
            ),
            OverloadSet(
                "voldermort",
                [
                    Function(
                        null,
                        "voldermort",
                        Type("Voldermort"),
                        [Parameter("int", "i", "", PSC.none)],
                    ),
                ]
            ),
            OverloadSet(
                "voldermortArray",
                [
                    Function(
                        null,
                        "voldermortArray",
                        Type("DasVoldermort[]"),
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
            Aggregate("DasVoldermort", Aggregate.Kind.struct_),
        ]
    );
}
