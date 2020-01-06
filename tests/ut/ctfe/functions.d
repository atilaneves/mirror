module ut.ctfe.functions;


import ut.ctfe;


@("call.add1")
unittest {
    import std.traits: Unqual;

    enum mod = module_!"modules.functions";
    enum add1 = mod.functionsByOverload[0];

    mixin(add1.importMixin);
    mixin(mod.identifier, `.`, add1.identifier, `(1, 2)`).should == 4;
    mixin(mod.identifier, `.`, add1.identifier, `(2, 3)`).should == 6;
    // or, easier...
    mixin(add1.callMixin(1, 2)).should == 4;
    auto arg = 2;
    mixin(add1.callMixin("arg", 2)).should == 5;
}


@("pointerMixin.add1")
unittest {
    static import modules.functions;
    import std.traits: Unqual;

    enum mod = module_!"modules.functions";
    enum add1 = mod.functionsByOverload[0];
    static assert(add1.identifier == "add1");

    auto add1Ptr = mixin(pointerMixin("add1"));
    static assert(is(Unqual!(typeof(add1Ptr)) ==
                     typeof(&__traits(getOverloads, modules.functions, "add1")[0])));

    add1Ptr(1, 2).should == 4;
    add1Ptr(2, 3).should == 6;
}


@("pointerMixin.withDefault")
unittest {
    static import modules.functions;
    import std.traits: Unqual;

    enum mod = module_!"modules.functions";
    enum withDefault = mod.functionsByOverload[2];
    static assert(withDefault.identifier == "withDefault");

    auto withDefaultPtr = mixin(pointerMixin("withDefault"));
    static assert(is(Unqual!(typeof(withDefaultPtr)) == typeof(&modules.functions.withDefault)));

    withDefaultPtr(1.1, 2.2).should ~ 3.3;
    // FIXME
    // pointerSignature doesn't take default arguments or function attributes into account
    // withDefaultPtr(1.1).should ~ 34.4;
}


@("functions.byOverload")
@safe pure unittest {
    static import modules.functions;
    import std.traits: PSC = ParameterStorageClass;

    enum mod = module_!"modules.functions";
    mod.functionsByOverload[].shouldBeSameSetAs(
        [
            Function(
                "modules.functions",
                &__traits(getOverloads, modules.functions, "add1")[0],
                "add1",
                Type("int"),
                [
                    Parameter("int", "i"),
                    Parameter("int", "j"),
                ],
            ),
            Function(
                "modules.functions",
                &__traits(getOverloads, modules.functions, "add1")[1],
                "add1",
                Type("double"),
                [
                    Parameter("double", "d0"),
                    Parameter("double", "d1"),
                ],
            ),
            Function(
                "modules.functions",
                &modules.functions.withDefault,
                "withDefault",
                Type("double"),
                [
                    Parameter("double", "fst"),
                    Parameter("double", "snd", "33.3"),
                ],
            ),
            Function(
                "modules.functions",
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
                "modules.functions",
                &modules.functions.exportedFunc,
                "exportedFunc",
                Type("void"),
                [],
            ),
            Function(
                "modules.functions",
                &modules.functions.externC,
                "externC",
                Type("void"),
                [],
            ),
            Function(
                "modules.functions",
                &modules.functions.externCpp,
                "externCpp",
                Type("void"),
                [],
            ),
            Function(
                "modules.functions",
                &modules.functions.identityInt,
                "identityInt",
                Type("int"),
                [Parameter("int", "x", "", PSC.none)],
            ),
            Function(
                "modules.functions",
                &modules.functions.voldermort,
                "voldermort",
                Type("Voldermort"),
                [Parameter("int", "i", "", PSC.none)],
            ),
            Function(
                "modules.functions",
                &modules.functions.voldermortArray,
                "voldermortArray",
                Type("DasVoldermort[]"),
                [Parameter("int", "i", "", PSC.none)],
            ),
            Function(
                "modules.functions",
                &modules.functions.concatFoo,
                "concatFoo",
                Type("string"),
                [
                    Parameter("string", "s0", "", PSC.none),
                    Parameter("int",    "i",  "", PSC.none),
                    Parameter("string", "s1", "", PSC.none),
                ],
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
                        "modules.functions",
                        &__traits(getOverloads, modules.functions, "add1")[0],
                        "add1",
                        Type("int"),
                        [
                            Parameter("int", "i"),
                            Parameter("int", "j"),
                        ],
                    ),
                    Function(
                        "modules.functions",
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
                        "modules.functions",
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
                        "modules.functions",
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
                        "modules.functions",
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
                        "modules.functions",
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
                        "modules.functions",
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
                        "modules.functions",
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
                        "modules.functions",
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
                        "modules.functions",
                        &modules.functions.voldermortArray,
                        "voldermortArray",
                        Type("DasVoldermort[]"),
                        [Parameter("int", "i", "", PSC.none)],
                    ),
                ]
            ),
            OverloadSet(
                "concatFoo",
                [
                    Function(
                        "modules.functions",
                        &modules.functions.concatFoo,
                        "concatFoo",
                        Type("string"),
                        [
                            Parameter("string", "s0", "", PSC.none),
                            Parameter("int",    "i",  "", PSC.none),
                            Parameter("string", "s1", "", PSC.none),
                        ],
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
