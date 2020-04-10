module ut.ctfe.functions;


import ut.ctfe;



@("callMixin.add1")
unittest {
    import std.traits: Unqual;

    enum mod = module_!"modules.functions";
    enum add1 = mod.functionsByOverload[0];

    mixin(add1.importMixin);

    mixin(add1.fullyQualifiedName, `(1, 2)`).should == 4;
    mixin(add1.fullyQualifiedName, `(2, 3)`).should == 6;

    // or, easier...
    mixin(add1.callMixin(1, 2)).should == 4;
    auto arg = 2;
    mixin(add1.callMixin("arg", 2)).should == 5;
}


@("pointer.byOverload.add1.0")
unittest {
    enum mod = module_!"modules.functions";
    enum add1 = mod.functionsByOverload[0];

    mixin(add1.importMixin);

    auto ptr = pointer!add1;
    static assert(is(typeof(ptr) == int function(int, int)));

    ptr(1, 2).should == 4;
    ptr(2, 3).should == 6;
}

@("pointer.byOverload.add1.1")
unittest {
    enum mod = module_!"modules.functions";
    enum add1 = mod.functionsByOverload[1];

    mixin(add1.importMixin);

    auto ptr = pointer!add1;
    static assert(is(typeof(ptr) == double function(double, double)));

    ptr(1.0, 2.0).should == 4.0;
    ptr(2.0, 3.0).should == 6.0;
}


@("pointer.bySymbol.add1")
unittest {
    enum mod = module_!"modules.functions";
    enum add1 = mod.functionsBySymbol[0];

    enum add1Int = add1.overloads[0];
    enum add1Double = add1.overloads[1];

    mixin(add1Int.importMixin);

    auto ptrInt = pointer!add1Int;
    static assert(is(typeof(ptrInt) == int function(int, int)));
    ptrInt(1, 2).should == 4;
    ptrInt(2, 3).should == 6;

    auto ptrDouble = pointer!add1Double;
    static assert(is(typeof(ptrDouble) == double function(double, double)));
    ptrDouble(1.0, 2.0).should == 4.0;
    ptrDouble(2.0, 3.0).should == 6.0;
}


@("pointer.byOverload.withDefault")
unittest {
    static import modules.functions;

    enum mod = module_!"modules.functions";
    enum withDefault = mod.functionsByOverload[2];
    static assert(withDefault.identifier == "withDefault");

    auto ptr = pointer!withDefault;
    (ptr is &modules.functions.withDefault).should == true;

    ptr(1.1, 2.2).should ~ 3.3;
    ptr(1.1).should ~ 34.4;
}


@("pointerMixin.byOverload.add1.0")
unittest {
    enum mod = module_!"modules.functions";
    enum add1 = mod.functionsByOverload[0];

    mixin(add1.importMixin);

    auto ptr = mixin(add1.pointerMixin);
    static assert(is(typeof(ptr) == int function(int, int)));

    ptr(1, 2).should == 4;
    ptr(2, 3).should == 6;
}


@("pointerMixin.byOverload.add1.1")
unittest {
    enum mod = module_!"modules.functions";
    enum add1 = mod.functionsByOverload[1];

    mixin(add1.importMixin);

    auto ptr = mixin(add1.pointerMixin);
    static assert(is(typeof(ptr) == double function(double, double)));

    ptr(1.0, 2.0).should == 4.0;
    ptr(2.0, 3.0).should == 6.0;
}


@("pointerMixin.bySymbol.add1")
unittest {
    enum mod = module_!"modules.functions";
    enum add1 = mod.functionsBySymbol[0];

    enum add1Int = add1.overloads[0];
    enum add1Double = add1.overloads[1];

    mixin(add1Int.importMixin);

    auto ptrInt = mixin(add1Int.pointerMixin);
    static assert(is(typeof(ptrInt) == int function(int, int)));
    ptrInt(1, 2).should == 4;
    ptrInt(2, 3).should == 6;

    auto ptrDouble = mixin(add1Double.pointerMixin);
    static assert(is(typeof(ptrDouble) == double function(double, double)));
    ptrDouble(1.0, 2.0).should == 4.0;
    ptrDouble(2.0, 3.0).should == 6.0;
}


@("pointerMixin.byOverload.withDefault")
unittest {
    static import modules.functions;

    enum mod = module_!"modules.functions";
    enum withDefault = mod.functionsByOverload[2];
    static assert(withDefault.identifier == "withDefault");

    auto ptr = mixin(withDefault.pointerMixin);
    (ptr is &modules.functions.withDefault).should == true;

    ptr(1.1, 2.2).should ~ 3.3;
    ptr(1.1).should ~ 34.4;
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
                0,
                "add1",
                Type("int"),
                [
                    Parameter("int", "i"),
                    Parameter("int", "j"),
                ],
            ),
            Function(
                "modules.functions",
                1,
                "add1",
                Type("double"),
                [
                    Parameter("double", "d0"),
                    Parameter("double", "d1"),
                ],
            ),
            Function(
                "modules.functions",
                0,
                "withDefault",
                Type("double"),
                [
                    Parameter("double", "fst"),
                    Parameter("double", "snd", "33.3"),
                ],
            ),
            Function(
                "modules.functions",
                0,
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
                0,
                "exportedFunc",
                Type("void"),
                [],
            ),
            Function(
                "modules.functions",
                0,
                "externC",
                Type("void"),
                [],
            ),
            Function(
                "modules.functions",
                0,
                "externCpp",
                Type("void"),
                [],
            ),
            Function(
                "modules.functions",
                0,
                "identityInt",
                Type("int"),
                [Parameter("int", "x", "", PSC.none)],
            ),
            Function(
                "modules.functions",
                0,
                "voldermort",
                Type("Voldermort"),
                [Parameter("int", "i", "", PSC.none)],
            ),
            Function(
                "modules.functions",
                0,
                "voldermortArray",
                Type("DasVoldermort[]"),
                [Parameter("int", "i", "", PSC.none)],
            ),
            Function(
                "modules.functions",
                0,
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
                        0,
                        "add1",
                        Type("int"),
                        [
                            Parameter("int", "i"),
                            Parameter("int", "j"),
                        ],
                    ),
                    Function(
                        "modules.functions",
                        1,
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
                        0,
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
                        0,
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
                        0,
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
                        0,
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
                        0,
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
                        0,
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
                        0,
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
                        0,
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
                        0,
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
