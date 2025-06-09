module ut.ctfe.reflection.functions;


import ut.ctfe.reflection;
import std.traits: PSC = ParameterStorageClass;


@("problems")
@safe pure unittest {
    // just to check there are no compilation errors
    static immutable mod = module_!"modules.problems"();
}


@("functionsByOverload.call.ct.addd.0")
@safe pure unittest {
    static immutable mod = module_!"modules.functions"();
    static immutable addd_0 = mod.functionsByOverload[0];

    mixin(addd_0.importMixin);
    alias addd_0Sym = mixin(addd_0.aliasMixin);
    static assert(is(typeof(&addd_0Sym) == int function(int, int) @safe @nogc pure nothrow));

    addd_0Sym(1, 2).should == 4;
    addd_0Sym(2, 3).should == 6;
}

@("functionsByOverload.call.ct.addd.1")
@safe pure unittest {
    static immutable mod = module_!"modules.functions"();
    static immutable addd_1 = mod.functionsByOverload[1];

    mixin(addd_1.importMixin);
    alias addd_1Sym = mixin(addd_1.aliasMixin);
    static assert(is(typeof(&addd_1Sym) == double function(double, double) @safe @nogc pure nothrow));

    addd_1Sym(1, 2).should == 5;
    addd_1Sym(2, 3).should == 7;
}

@("functionsByOverload.call.rt.pointer.addd.0")
@safe pure unittest {
    const mod = module_!"modules.functions"();
    const addd_0 = mod.functionsByOverload[0];
    auto funPtr = () @trusted {
        return cast(int function(int, int) @safe @nogc pure nothrow) addd_0.pointerFunc();
    }();
    funPtr(1, 2).should == 4;
    funPtr(2, 3).should == 6;
}

@("functionsBySymbol.call.addd")
@safe pure unittest {
    static immutable mod = module_!"modules.functions"();
    static immutable addd = mod.functionsBySymbol[0];
    static assert(addd.identifier == "addd");

    mixin(addd.importMixin);
    alias addd_0Sym = mixin(addd.overloads[0].aliasMixin);
    alias addd_1Sym = mixin(addd.overloads[1].aliasMixin);

    static assert(is(typeof(&addd_0Sym) == int function(int, int) @safe @nogc pure nothrow));
    static assert(is(typeof(&addd_1Sym) == double function(double, double) @safe @nogc pure nothrow));

    addd_1Sym(1, 2).should == 5;
    addd_1Sym(2, 3).should == 7;
}


@("visibility.public")
@safe pure unittest {
    static immutable mod = module_!"modules.functions"();
    static immutable func = mod.functionsByOverload[0];
    func.visibility.should == Visibility.public_;
}

@("visibility.export")
@safe pure unittest {
    static immutable mod = module_!"modules.functions"();
    static immutable func = mod.functionsByOverload[4];
    func.visibility.should == Visibility.export_;
}
