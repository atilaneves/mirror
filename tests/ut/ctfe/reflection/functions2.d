module ut.ctfe.reflection.functions2;


import ut;
import mirror.ctfe.reflection2;


@("add1.callMixin")
unittest {
    import std.traits: Unqual;

    enum mod = module_!"modules.functions"();
    enum add1 = mod.functionsByOverload[0];
    pragma(msg, mod.functionsByOverload);

    pragma(msg, add1.importMixin);
    mixin(add1.importMixin);

    mixin(add1.fullyQualifiedName)(1, 2).should == 4;
    mixin(add1.fullyQualifiedName)(2, 3).should == 6;
}

@("add1.equality")
unittest {
    import std.traits: Unqual;

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
