module ut.meta.functions;


import ut.meta;
import mirror.traits: Parameter;
import std.meta: AliasSeq;


@("functions.bySymbol")
@safe pure unittest {
    alias mod = Module!("modules.functions");
    import modules.functions;

    alias expected = AliasSeq!(
        FunctionSymbol!(add1, Protection.public_, Linkage.D),
        FunctionSymbol!(withDefault, Protection.public_, Linkage.D),
        FunctionSymbol!(storageClasses, Protection.public_, Linkage.D),
        FunctionSymbol!(exportedFunc, Protection.export_, Linkage.D),
        FunctionSymbol!(externC, Protection.public_, Linkage.C),
        FunctionSymbol!(externCpp, Protection.public_, Linkage.Cpp),
        FunctionSymbol!(identityInt, Protection.public_, Linkage.D, "identityInt", modules.functions),
        FunctionSymbol!(voldermort, Protection.public_, Linkage.D),
        FunctionSymbol!(voldermortArray, Protection.public_, Linkage.D),
        FunctionSymbol!(concatFoo, Protection.public_, Linkage.D),
    );

    // pragma(msg, "\n", mod.FunctionsBySymbol.stringof, "\n");
    shouldEqual!(mod.FunctionsBySymbol, expected);

    static assert(mod.FunctionsBySymbol[0].overloads.length == 2); // add1
    static foreach(i; 1..expected.length)
        static assert(mod.FunctionsBySymbol[i].overloads.length == 1); // everything else
}


@("functions.byOverload")
@safe pure unittest {
    alias mod = Module!("modules.functions");
    import modules.functions;

    alias add1Int = __traits(getOverloads, modules.functions, "add1")[0];
    alias add1Double = __traits(getOverloads, modules.functions, "add1")[1];

    alias expected = AliasSeq!(
        FunctionOverload!(add1Int, Protection.public_, Linkage.D),
        FunctionOverload!(add1Double, Protection.public_, Linkage.D, "add1", modules.functions, 1),
        FunctionOverload!(withDefault, Protection.public_, Linkage.D),
        FunctionOverload!(storageClasses, Protection.public_, Linkage.D),
        FunctionOverload!(exportedFunc, Protection.export_, Linkage.D),
        FunctionOverload!(externC, Protection.public_, Linkage.C),
        FunctionOverload!(externCpp, Protection.public_, Linkage.Cpp),
        FunctionOverload!(identityInt, Protection.public_, Linkage.D, "identityInt", modules.functions),
        FunctionOverload!(voldermort, Protection.public_, Linkage.D),
        FunctionOverload!(voldermortArray, Protection.public_, Linkage.D),
        FunctionOverload!(concatFoo, Protection.public_, Linkage.D),
    );

    // pragma(msg, "\n", mod.FunctionsByOverload.stringof, "\n");
    shouldEqual!(mod.FunctionsByOverload, expected);
}


@("problems")
@safe pure unittest {
    alias mod = Module!("modules.problems");
    static assert(mod.FunctionsBySymbol.length == 0, mod.FunctionsBySymbol.stringof);
}



@("parameters.add1.bySymbol")
@safe pure unittest {

    alias mod = Module!("modules.functions");
    alias add1Int = mod.FunctionsBySymbol[0].overloads[0];
    alias add1Double = mod.FunctionsBySymbol[0].overloads[1];
    alias withDefaults = mod.FunctionsBySymbol[1].overloads[0];

    shouldEqual!(
        add1Int.parameters,
        AliasSeq!(
            Parameter!(int, void, "i"),
            Parameter!(int, void, "j"),
        )
    );

    shouldEqual!(
        add1Double.parameters,
        AliasSeq!(
            Parameter!(double, void, "d0"),
            Parameter!(double, void, "d1"),
        )
    );

    shouldEqual!(
        withDefaults.parameters,
        AliasSeq!(
            Parameter!(double, void, "fst"),
            Parameter!(double, 33.3, "snd"),
        )
    );
}


@("parameters.add1.byOverload")
@safe pure unittest {
    alias mod = Module!("modules.functions");
    alias add1Int = mod.FunctionsByOverload[0];
    alias add1Double = mod.FunctionsByOverload[1];

    shouldEqual!(
        add1Int.parameters,
        AliasSeq!(
            Parameter!(int, void, "i"),
            Parameter!(int, void, "j"),
        )
    );

    shouldEqual!(
        add1Double.parameters,
        AliasSeq!(
            Parameter!(double, void, "d0"),
            Parameter!(double, void, "d1"),
        )
    );
}



@("return.bySymbol")
@safe pure unittest {
    import std.meta: staticMap;

    alias mod = Module!("modules.functions");
    alias functions = mod.FunctionsBySymbol;

    static assert(is(functions[0].overloads[0].ReturnType == int));
    static assert(is(functions[0].overloads[1].ReturnType == double));
    static assert(is(functions[1].overloads[0].ReturnType == double));
    static assert(is(functions[2].overloads[0].ReturnType == void));
}


@("return.byOverload")
@safe pure unittest {
    import std.meta: staticMap;
    import std.traits: ReturnType;
    static import modules.functions;

    alias mod = Module!("modules.functions");
    alias return_(alias F) = F.ReturnType;
    alias returnTypes = staticMap!(return_, mod.FunctionsByOverload);

    shouldEqual!(
        returnTypes,
        AliasSeq!(
            int, double, double, void, void, void, void, int,
            ReturnType!(modules.functions.voldermort),
            ReturnType!(modules.functions.voldermortArray),
            string,
        ),
    );
}
