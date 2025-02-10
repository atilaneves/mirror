module ut.ctfe.reflection.functions2;


import ut;
import mirror.ctfe.reflection2;
import std.traits: PSC = ParameterStorageClass;


@("problems")
@safe pure unittest {
    // just to check there are no compilation errors
    enum mod = module_!"modules.problems"();
}


@("functionsByOverload.call.addd.0")
@safe pure unittest {
    enum mod = module_!"modules.functions"();
    enum addd_0 = mod.functionsByOverload[0];

    mixin(addd_0.importMixin);
    alias addd_0Sym = mixin(addd_0.symbolMixin);
    static assert(is(typeof(&addd_0Sym) == int function(int, int) @safe @nogc pure nothrow));

    addd_0Sym(1, 2).should == 4;
    addd_0Sym(2, 3).should == 6;
}

@("functionsByOverload.call.addd.1")
@safe pure unittest {
    enum mod = module_!"modules.functions"();
    enum addd_1 = mod.functionsByOverload[1];

    mixin(addd_1.importMixin);
    alias addd_1Sym = mixin(addd_1.symbolMixin);
    static assert(is(typeof(&addd_1Sym) == double function(double, double) @safe @nogc pure nothrow));

    addd_1Sym(1, 2).should == 5;
    addd_1Sym(2, 3).should == 7;
}

@("visibility.public")
@safe pure unittest {
    enum mod = module_!"modules.functions"();
    enum func = mod.functionsByOverload[0];
    func.visibility.should == Visibility.public_;
}

@("visibility.export")
@safe pure unittest {
    enum mod = module_!"modules.functions"();
    enum func = mod.functionsByOverload[4];
    func.visibility.should == Visibility.export_;
}


@("functionsByOverload.equality")
@safe pure unittest {
    enum mod = module_!"modules.functions"();
    enum functions = mod.functionsByOverload[0..7]; // FIXME

    functions.should == [
        Function(
            "modules.functions.addd",
            0,
            Type("int"),
            [
                Parameter(
                    Type("int"),
                    "i",
                    PSC.none,
                ),
                Parameter(
                    Type("int"),
                    "j",
                    PSC.none,
                ),
            ],
            "public",
            "D",
        ),
        Function(
            "modules.functions.addd",
            1,
            Type("double"),
            [
                Parameter(
                    Type("double"),
                    "d0",
                    PSC.none,
                ),
                Parameter(
                    Type("double"),
                    "d1",
                    PSC.none,
                ),
            ],
            "public",
            "D",
        ),
        Function(
            "modules.functions.withDefault",
            0,
            Type("double"),
            [
                Parameter(
                    Type("double"),
                    "fst",
                    PSC.none,
                ),
                Parameter(
                    Type("double"),
                    "snd",
                    PSC.none,
                    "33.3",
                ),
            ],
            "public",
            "D",
        ),
        Function(
            "modules.functions.storageClasses",
            0,
            Type("void"),
            [
                Parameter(Type("int"), "normal", PSC.none),
                Parameter(Type("int*"), "returnScope", PSC.return_ | PSC.scope_),
                Parameter(Type("int"), "out_", PSC.out_),
                Parameter(Type("int"), "ref_", PSC.ref_),
                Parameter(Type("int"), "lazy_", PSC.lazy_),
            ],
            "public",
            "D",
        ),
        Function(
            "modules.functions.exportedFunc",
            0,
            Type("void"),
            [],
            "export",
            "D",
        ),
        Function(
            "modules.functions.externC",
            0,
            Type("void"),
            [],
            "public",
            "C",
        ),
        Function(
            "modules.functions.externCpp",
            0,
            Type("void"),
            [],
            "public",
            "C++",
        ),
    ];
}
