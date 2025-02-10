module ut.ctfe.reflection.functions2;


import ut;
import mirror.ctfe.reflection2;


@("problems")
@safe pure unittest {
    // just to check there are no compilation errors
    enum mod = module_!"modules.problems"();
}


@("functionsByOverload.call.0")
@safe pure unittest {
    enum mod = module_!"modules.functions"();
    enum addd_0 = mod.functionsByOverload[0];

    mixin(addd_0.importMixin);
    alias addd_0Sym = mixin(addd_0.symbolMixin);
    static assert(is(typeof(&addd_0Sym) == int function(int, int) @safe @nogc pure nothrow));

    addd_0Sym(1, 2).should == 4;
    addd_0Sym(2, 3).should == 6;
}

@("functionsByOverload.call.1")
@safe pure unittest {
    enum mod = module_!"modules.functions"();
    enum addd_1 = mod.functionsByOverload[1];

    mixin(addd_1.importMixin);
    alias addd_1Sym = mixin(addd_1.symbolMixin);
    static assert(is(typeof(&addd_1Sym) == double function(double, double) @safe @nogc pure nothrow));

    addd_1Sym(1, 2).should == 5;
    addd_1Sym(2, 3).should == 7;
}


@("functionsByOverload.equality")
@safe pure unittest {
    enum mod = module_!"modules.functions"();
    enum functions = mod.functionsByOverload[0..2]; // FIXME

    functions.should == [
        Function(
            "modules.functions",
            0,
            "addd",
            Type("int"),
            [
                Parameter(
                    Type("int"),
                    "i",
                ),
                Parameter(
                    Type("int"),
                    "j",
                ),
            ],
        ),
        Function(
            "modules.functions",
            1,
            "addd",
            Type("double"),
            [
                Parameter(
                    Type("double"),
                    "d0",
                ),
                Parameter(
                    Type("double"),
                    "d1",
                ),
            ],
        ),
    ];
}
