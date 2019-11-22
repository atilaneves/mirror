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
            Function(
                "voldermortArray",
                Type("DasVoldermort[]"),
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
            OverloadSet(
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
            OverloadSet(
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
            OverloadSet(
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
            OverloadSet(
                "exportedFunc",
                [
                    Function(
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
