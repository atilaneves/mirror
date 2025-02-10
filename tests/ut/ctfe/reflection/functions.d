module ut.ctfe.reflection.functions;


import ut.ctfe.reflection;


@("callMixin.addd")
unittest {
    import std.traits: Unqual;

    enum mod = module_!"modules.functions";
    enum addd = mod.functionsByOverload[0];

    mixin(addd.importMixin);

    mixin(addd.fullyQualifiedName, `(1, 2)`).should == 4;
    mixin(addd.fullyQualifiedName, `(2, 3)`).should == 6;

    // or, easier...
    mixin(addd.callMixin(1, 2)).should == 4;
    auto arg = 2;
    mixin(addd.callMixin("arg", 2)).should == 5;
}


@("pointer.byOverload.addd.0")
unittest {
    enum mod = module_!"modules.functions";
    enum addd = mod.functionsByOverload[0];

    mixin(addd.importMixin);

    auto ptr = pointer!addd;
    static assert(is(typeof(ptr) == int function(int, int)));

    ptr(1, 2).should == 4;
    ptr(2, 3).should == 6;
}

@("pointer.byOverload.addd.1")
unittest {
    enum mod = module_!"modules.functions";
    enum addd = mod.functionsByOverload[1];

    mixin(addd.importMixin);

    auto ptr = pointer!addd;
    static assert(is(typeof(ptr) == double function(double, double)));

    ptr(1.0, 2.0).should == 5.0;
    ptr(2.0, 3.0).should == 7.0;
}


@("pointer.bySymbol.addd")
unittest {
    enum mod = module_!"modules.functions";
    enum addd = mod.functionsBySymbol[0];

    enum adddInt = addd.overloads[0];
    enum adddDouble = addd.overloads[1];

    mixin(adddInt.importMixin);

    auto ptrInt = pointer!adddInt;
    static assert(is(typeof(ptrInt) == int function(int, int)));
    ptrInt(1, 2).should == 4;
    ptrInt(2, 3).should == 6;

    auto ptrDouble = pointer!adddDouble;
    static assert(is(typeof(ptrDouble) == double function(double, double)));
    ptrDouble(1.0, 2.0).should == 5.0;
    ptrDouble(2.0, 3.0).should == 7.0;
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


@("pointerMixin.byOverload.addd.0")
unittest {
    enum mod = module_!"modules.functions";
    enum addd = mod.functionsByOverload[0];

    mixin(addd.importMixin);

    auto ptr = mixin(addd.pointerMixin);
    static assert(is(typeof(ptr) == int function(int, int)));

    ptr(1, 2).should == 4;
    ptr(2, 3).should == 6;
}


@("pointerMixin.byOverload.addd.1")
unittest {
    enum mod = module_!"modules.functions";
    enum addd = mod.functionsByOverload[1];

    mixin(addd.importMixin);

    auto ptr = mixin(addd.pointerMixin);
    static assert(is(typeof(ptr) == double function(double, double)));

    ptr(1.0, 2.0).should == 5.0;
    ptr(2.0, 3.0).should == 7.0;
}


@("pointerMixin.bySymbol.addd")
unittest {
    enum mod = module_!"modules.functions";
    enum addd = mod.functionsBySymbol[0];

    enum adddInt = addd.overloads[0];
    enum adddDouble = addd.overloads[1];

    mixin(adddInt.importMixin);

    auto ptrInt = mixin(adddInt.pointerMixin);
    static assert(is(typeof(ptrInt) == int function(int, int)));
    ptrInt(1, 2).should == 4;
    ptrInt(2, 3).should == 6;

    auto ptrDouble = mixin(adddDouble.pointerMixin);
    static assert(is(typeof(ptrDouble) == double function(double, double)));
    ptrDouble(1.0, 2.0).should == 5.0;
    ptrDouble(2.0, 3.0).should == 7.0;
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
    import std.traits: PSC = ParameterStorageClass, ReturnType;

    enum mod = module_!"modules.functions";
    mod.functionsByOverload[].shouldBeSameSetAs(
        [
            Function(
                "modules.functions",
                0,
                "addd",
                Type("int", int.sizeof),
                [
                    Parameter(type!int, "i"),
                    Parameter(type!int, "j"),
                ],
            ),
            Function(
                "modules.functions",
                1,
                "addd",
                Type("double", double.sizeof),
                [
                    Parameter(type!double, "d0"),
                    Parameter(type!double, "d1"),
                ],
            ),
            Function(
                "modules.functions",
                0,
                "withDefault",
                Type("double", double.sizeof),
                [
                    Parameter(type!double, "fst"),
                    Parameter(type!double, "snd", "33.3"),
                ],
            ),
            Function(
                "modules.functions",
                0,
                "storageClasses",
                Type("void", 1),
                [
                    Parameter(type!int, "normal", "", PSC.none),
                    Parameter(type!(int*), "returnScope", "", PSC.return_ | PSC.scope_),
                    Parameter(type!int, "out_", "", PSC.out_),
                    Parameter(type!int, "ref_", "", PSC.ref_),
                    Parameter(type!int, "lazy_", "", PSC.lazy_),
                ]
            ),
            Function(
                "modules.functions",
                0,
                "exportedFunc",
                Type("void", 1),
                [],
            ),
            Function(
                "modules.functions",
                0,
                "externC",
                Type("void", 1),
                [],
            ),
            Function(
                "modules.functions",
                0,
                "externCpp",
                Type("void", 1),
                [],
            ),
            Function(
                "modules.functions",
                0,
                "identityInt",
                Type("int", int.sizeof),
                [Parameter(type!int, "x", "", PSC.none)],
            ),
            Function(
                "modules.functions",
                0,
                "voldemort",
                Type("modules.functions.voldemort.Voldemort", ReturnType!(modules.functions.voldemort).sizeof),
                [Parameter(type!int, "i", "", PSC.none)],
            ),
            Function(
                "modules.functions",
                0,
                "voldemortArray",
                Type("modules.functions.voldemortArray.DasVoldemort[]", ReturnType!(modules.functions.voldemortArray).sizeof),
                [Parameter(type!int, "i", "", PSC.none)],
            ),
            Function(
                "modules.functions",
                0,
                "concatFoo",
                Type("string", string.sizeof),
                [
                    Parameter(type!string, "s0", "", PSC.none),
                    Parameter(type!int,    "i",  "", PSC.none),
                    Parameter(type!string, "s1", "", PSC.none),
                ],
            ),
        ]
    );
}


@("functions.bySymbol")
@safe pure unittest {
    static import modules.functions;
    import std.traits: PSC = ParameterStorageClass, ReturnType;

    enum mod = module_!"modules.functions";
    mod.functionsBySymbol[].shouldBeSameSetAs(
        [
            OverloadSet(
                "addd",
                [
                    Function(
                        "modules.functions",
                        0,
                        "addd",
                        Type("int", int.sizeof),
                        [
                            Parameter(type!int, "i"),
                            Parameter(type!int, "j"),
                        ],
                    ),
                    Function(
                        "modules.functions",
                        1,
                        "addd",
                        Type("double", double.sizeof),
                        [
                            Parameter(type!double, "d0"),
                            Parameter(type!double, "d1"),
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
                        Type("double", double.sizeof),
                        [
                            Parameter(type!double, "fst"),
                            Parameter(type!double, "snd", "33.3"),
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
                        Type("void", 1),
                        [
                            Parameter(type!int, "normal", "", PSC.none),
                            Parameter(type!(int*), "returnScope", "", PSC.return_ | PSC.scope_),
                            Parameter(type!int, "out_", "", PSC.out_),
                            Parameter(type!int, "ref_", "", PSC.ref_),
                            Parameter(type!int, "lazy_", "", PSC.lazy_),
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
                        Type("void", 1),
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
                        Type("void", 1),
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
                        Type("void", 1),
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
                        Type("int", int.sizeof),
                        [Parameter(type!int, "x", "", PSC.none)],
                    ),
                ]
            ),
            OverloadSet(
                "voldemort",
                [
                    Function(
                        "modules.functions",
                        0,
                        "voldemort",
                        Type(
                            "modules.functions.voldemort.Voldemort",
                            ReturnType!(modules.functions.voldemort).sizeof,
                        ),
                        [Parameter(type!int, "i", "", PSC.none)],
                    ),
                ]
            ),
            OverloadSet(
                "voldemortArray",
                [
                    Function(
                        "modules.functions",
                        0,
                        "voldemortArray",
                        Type(
                            "modules.functions.voldemortArray.DasVoldemort[]",
                            ReturnType!(modules.functions.voldemortArray).sizeof,
                        ),
                        [Parameter(type!int, "i", "", PSC.none)],
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
                        Type("string", string.sizeof),
                        [
                            Parameter(type!string, "s0", "", PSC.none),
                            Parameter(type!int,    "i",  "", PSC.none),
                            Parameter(type!string, "s1", "", PSC.none),
                        ],
                    ),

                ]
            ),
        ]
    );
}


@("functions.allAggregates")
@safe pure unittest {

    enum mod = module_!"modules.functions";

    mod.allAggregates[].shouldBeSameSetAs(
        [
            Aggregate(
                "modules.functions.voldemort.Voldemort",
                Aggregate.Kind.struct_,
                [Variable("int", "i")],
            ),
            Aggregate(
                "modules.functions.voldemortArray.DasVoldemort",
                Aggregate.Kind.struct_,
                [Variable("int", "i")],
            ),
        ]
    );
}
