module ut.meta.functions;


import ut.meta;
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
    );

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
        FunctionOverload!(add1Double, Protection.public_, Linkage.D),
        FunctionOverload!(withDefault, Protection.public_, Linkage.D),
        FunctionOverload!(storageClasses, Protection.public_, Linkage.D),
        FunctionOverload!(exportedFunc, Protection.export_, Linkage.D),
        FunctionOverload!(externC, Protection.public_, Linkage.C),
        FunctionOverload!(externCpp, Protection.public_, Linkage.Cpp),
        FunctionOverload!(identityInt, Protection.public_, Linkage.D, "identityInt", modules.functions),
    );

    shouldEqual!(mod.FunctionsByOverload, expected);
}


@("problems")
@safe pure unittest {
    alias mod = Module!("modules.problems");
    static assert(mod.FunctionsBySymbol.length == 0, mod.FunctionsBySymbol.stringof);
}


@("parameters.add1.bySymbol")
@safe pure unittest {
    import modules.functions;

    alias func = FunctionSymbol!add1;
    alias parameters = AliasSeq!(func.parameters);

    alias expected = AliasSeq!(
        Parameter!(int, void, "i"),
        Parameter!(int, void, "j"),
    );

    shouldEqual!(parameters, expected);
}


@("parameters.add1.bySymbol")
@safe pure unittest {
    alias mod = Module!("modules.functions");
    alias add1Int = mod.FunctionsBySymbol[0];
    alias storageClasses = mod.FunctionsBySymbol[2];

    shouldEqual!(
        add1Int.parameters,
        AliasSeq!(
            Parameter!(int, void, "i"),
            Parameter!(int, void, "j"),
        )
    );

    shouldEqual!(
        storageClasses.parameters,
        AliasSeq!(
            Parameter!(int, void, "normal"),
            Parameter!(int*, void, "returnScope"),
            Parameter!(int, void, "out_"),
            Parameter!(int, void, "ref_"),
            Parameter!(int, void, "lazy_"),
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
    alias return_(alias F) = F.ReturnType;
    alias returnTypes = staticMap!(return_, mod.FunctionsBySymbol);

    shouldEqual!(
        returnTypes,
        AliasSeq!(
            // misses the add1 double overload
            int, double, void, void, void, void, int,
        ),
    );
}


@("return.byOverload")
@safe pure unittest {
    import std.meta: staticMap;

    alias mod = Module!("modules.functions");
    alias return_(alias F) = F.ReturnType;
    alias returnTypes = staticMap!(return_, mod.FunctionsByOverload);

    shouldEqual!(
        returnTypes,
        AliasSeq!(
            int, double, double, void, void, void, void, int,
        ),
    );
}
