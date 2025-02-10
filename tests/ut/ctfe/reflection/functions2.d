module ut.ctfe.reflection.functions2;


import ut;
import mirror.ctfe.reflection2;


@("problems")
unittest {
    // just to check there are no compilation errors
    enum mod = module_!"modules.problems"();
}


@("functionsByOverload.call.0")
unittest {
    enum mod = module_!"modules.functions"();
    enum addd_0 = mod.functionsByOverload[0];

    mixin(addd_0.importMixin);
    alias addd_0Sym = mixin(addd_0.fullyQualifiedName);

    addd_0Sym(1, 2).should == 4;
    addd_0Sym(2, 3).should == 6;
}

@("functionsByOverload.call.1")
unittest {
    enum mod = module_!"modules.functions"();
    enum addd_1 = mod.functionsByOverload[1];

    mixin(addd_1.importMixin);
    alias addd_1Sym = mixin(addd_1.fullyQualifiedName);

    addd_1Sym(1, 2).should == 4;
    addd_1Sym(2, 3).should == 6;
}


@("functionsByOverload.equality")
unittest {
    enum mod = module_!"modules.functions"();
    enum addd_0 = mod.functionsByOverload[0];
    addd_0.should == Function(
        "modules.functions",
        0,
        "addd",
    );

    enum addd_1= mod.functionsByOverload[1];
    addd_1.should == Function(
        "modules.functions",
        1,
        "addd",
    );
}
