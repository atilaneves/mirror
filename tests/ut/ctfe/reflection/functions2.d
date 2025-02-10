module ut.ctfe.reflection.functions2;


import ut;
import mirror.ctfe.reflection2;


@("problems")
unittest {
    // just to check there are no compilation errors
    enum mod = module_!"modules.problems"();
}


@("add1.callMixin")
unittest {
    enum mod = module_!"modules.functions"();
    enum add1 = mod.functionsByOverload[0];

    mixin(add1.importMixin);
    alias add1Sym = mixin(add1.fullyQualifiedName);

    add1Sym(1, 2).should == 4;
    add1Sym(2, 3).should == 6;
}


@("add1.equality")
unittest {
    enum mod = module_!"modules.functions"();
    enum add1_0 = mod.functionsByOverload[0];
    add1_0.should == Function(
        "modules.functions",
        0,
        "add1",
    );

    enum add1_1= mod.functionsByOverload[1];
    add1_1.should == Function(
        "modules.functions",
        1,
        "add1",
    );
}
