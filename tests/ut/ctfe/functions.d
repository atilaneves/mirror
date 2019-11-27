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
                &__traits(getOverloads, modules.functions, "add1")[0],
                "add1",
                Type("int"),
                [
                    Parameter("int", "i"),
                    Parameter("int", "j"),
                ],
            ),
            Function(
                &__traits(getOverloads, modules.functions, "add1")[1],
                "add1",
                Type("double"),
                [
                    Parameter("double", "d0"),
                    Parameter("double", "d1"),
                ],
            ),
            Function(
                &modules.functions.withDefault,
                "withDefault",
                Type("double"),
                [
                    Parameter("double", "fst"),
                    Parameter("double", "snd", "33.3"),
                ],
            ),
            Function(
                &modules.functions.storageClasses,
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
                &modules.functions.exportedFunc,
                "exportedFunc",
                Type("void"),
                [],
            ),
            Function(
                &modules.functions.externC,
                "externC",
                Type("void"),
                [],
            ),
            Function(
                &modules.functions.externCpp,
                "externCpp",
                Type("void"),
                [],
            ),
            Function(
                &modules.functions.identityInt,
                "identityInt",
                Type("int"),
                [Parameter("int", "x", "", PSC.none)],
            ),
            Function(
                &modules.functions.voldermort,
                "voldermort",
                Type("Voldermort"),
                [Parameter("int", "i", "", PSC.none)],
            ),
            Function(
                &modules.functions.voldermortArray,
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
                        &__traits(getOverloads, modules.functions, "add1")[0],
                        "add1",
                        Type("int"),
                        [
                            Parameter("int", "i"),
                            Parameter("int", "j"),
                        ],
                    ),
                    Function(
                        &__traits(getOverloads, modules.functions, "add1")[1],
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
                        &modules.functions.withDefault,
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
                        &modules.functions.storageClasses,
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
                        &modules.functions.exportedFunc,
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
                        &modules.functions.externC,
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
                        &modules.functions.externCpp,
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
                        &modules.functions.identityInt,
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
                        &modules.functions.voldermort,
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
                        &modules.functions.voldermortArray,
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
