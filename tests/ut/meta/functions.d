module ut.meta.functions;


import ut.meta;
import std.meta: AliasSeq;


@("functions")
@safe pure unittest {
    alias mod = Module!("modules.functions");
    import modules.functions;

    alias expected = AliasSeq!(
        Function!(add1, Protection.public_, Linkage.D),
        Function!(withDefault, Protection.public_, Linkage.D),
        Function!(storageClasses, Protection.public_, Linkage.D),
        Function!(exportedFunc, Protection.export_, Linkage.D),
        Function!(externC, Protection.public_, Linkage.C),
        Function!(externCpp, Protection.public_, Linkage.Cpp),
        Function!(identityInt, Protection.public_, Linkage.D, "identityInt", modules.functions),
    );

    shouldEqual!(mod.Functions, expected);

    static assert(mod.Functions[0].overloads.length == 2); // add1
    static foreach(i; 1..expected.length)
        static assert(mod.Functions[i].overloads.length == 1); // everything else
}


@("problems")
@safe pure unittest {
    alias mod = Module!("modules.problems");
    static assert(mod.Functions.length == 0, mod.Functions.stringof);
}


@("parameters.add1")
@safe pure unittest {
    import modules.functions;

    alias func = Function!add1;
    alias parameters = AliasSeq!(func.parameters);

    alias expected = AliasSeq!(
        Parameter!(int, void, "i"),
        Parameter!(int, void, "j"),
    );

    shouldEqual!(parameters, expected);
}


@("return")
@safe pure unittest {
    import modules.functions;
    static assert(is(Function!add1.ReturnType == int));
    static assert(is(Function!withDefault.ReturnType == double));
    static assert(is(Function!storageClasses.ReturnType == void));
    static assert(is(Function!exportedFunc.ReturnType == void));
    static assert(is(Function!externC.ReturnType == void));
    static assert(is(Function!identityInt.ReturnType == int));
}
