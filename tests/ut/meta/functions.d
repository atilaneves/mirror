module ut.meta.functions;


import ut.meta;
import std.meta: AliasSeq;


@("functions.bySymbol")
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
    static assert(mod.Functions.length == 0, mod.Functions.stringof);
}


@("parameters.add1.bySymbol")
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


@("parameters.add1.bySymbol")
@safe pure unittest {
    import modules.functions;

    alias mod = Module!("modules.functions");
    alias func = mod.Functions[0];
    alias parameters = AliasSeq!(func.parameters);

    alias expected = AliasSeq!(
        Parameter!(int, void, "i"),
        Parameter!(int, void, "j"),
    );

    shouldEqual!(parameters, expected);
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
    alias returnTypes = staticMap!(return_, mod.Functions);

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
