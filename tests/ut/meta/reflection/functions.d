module ut.meta.reflection.functions;


import ut.meta.reflection;
import mirror.meta.traits: Parameter;
import std.meta: AliasSeq;


@("functions.bySymbol")
@safe pure unittest {
    alias mod = Module!("modules.functions");
    import modules.functions;

    alias expected = AliasSeq!(
        FunctionSymbol!(addd, Protection.public_, Linkage.D),
        FunctionSymbol!(withDefault, Protection.public_, Linkage.D),
        FunctionSymbol!(storageClasses, Protection.public_, Linkage.D),
        FunctionSymbol!(exportedFunc, Protection.export_, Linkage.D),
        FunctionSymbol!(externC, Protection.public_, Linkage.C),
        FunctionSymbol!(externCpp, Protection.public_, Linkage.Cpp),
        FunctionSymbol!(identityInt, Protection.public_, Linkage.D, "identityInt", modules.functions),
        FunctionSymbol!(voldemort, Protection.public_, Linkage.D),
        FunctionSymbol!(voldemortArray, Protection.public_, Linkage.D),
        FunctionSymbol!(concatFoo, Protection.public_, Linkage.D),
    );

    // pragma(msg, "\n", mod.FunctionsBySymbol.stringof, "\n");
    shouldEqual!(mod.FunctionsBySymbol, expected);

    static assert(mod.FunctionsBySymbol[0].overloads.length == 2); // addd
    static foreach(i; 1..expected.length)
        static assert(mod.FunctionsBySymbol[i].overloads.length == 1); // everything else
}


@("functions.byOverload")
@safe pure unittest {
    alias mod = Module!("modules.functions");
    import modules.functions;

    alias adddInt = __traits(getOverloads, modules.functions, "addd")[0];
    alias adddDouble = __traits(getOverloads, modules.functions, "addd")[1];

    alias expected = AliasSeq!(
        FunctionOverload!(adddInt, Protection.public_, Linkage.D),
        FunctionOverload!(adddDouble, Protection.public_, Linkage.D, "addd", modules.functions, 1),
        FunctionOverload!(withDefault, Protection.public_, Linkage.D),
        FunctionOverload!(storageClasses, Protection.public_, Linkage.D),
        FunctionOverload!(exportedFunc, Protection.export_, Linkage.D),
        FunctionOverload!(externC, Protection.public_, Linkage.C),
        FunctionOverload!(externCpp, Protection.public_, Linkage.Cpp),
        FunctionOverload!(identityInt, Protection.public_, Linkage.D, "identityInt", modules.functions),
        FunctionOverload!(voldemort, Protection.public_, Linkage.D),
        FunctionOverload!(voldemortArray, Protection.public_, Linkage.D),
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



@("parameters.addd.bySymbol")
@safe pure unittest {

    alias mod = Module!("modules.functions");
    alias adddInt = mod.FunctionsBySymbol[0].overloads[0];
    alias adddDouble = mod.FunctionsBySymbol[0].overloads[1];
    alias withDefaults = mod.FunctionsBySymbol[1].overloads[0];

    shouldEqual!(
        adddInt.parameters,
        AliasSeq!(
            Parameter!(int, void, "i"),
            Parameter!(int, void, "j"),
        )
    );

    shouldEqual!(
        adddDouble.parameters,
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


@("parameters.addd.byOverload")
@safe pure unittest {
    alias mod = Module!("modules.functions");
    alias adddInt = mod.FunctionsByOverload[0];
    alias adddDouble = mod.FunctionsByOverload[1];

    shouldEqual!(
        adddInt.parameters,
        AliasSeq!(
            Parameter!(int, void, "i"),
            Parameter!(int, void, "j"),
        )
    );

    shouldEqual!(
        adddDouble.parameters,
        AliasSeq!(
            Parameter!(double, void, "d0"),
            Parameter!(double, void, "d1"),
        )
    );
}


@("parameters.storageClasses")
@safe pure unittest {

    import std.traits: STC = ParameterStorageClass;

    alias mod = Module!("modules.functions");
    alias storageClasses = mod.FunctionsByOverload[3];

    // pragma(msg, "\n", storageClasses.parameters.stringof, "\n");

    shouldEqual!(
        storageClasses.parameters,
        AliasSeq!(
            Parameter!(int, void, "normal", STC.none),
            Parameter!(int*, void, "returnScope", STC.return_ | STC.scope_),
            Parameter!(int, void, "out_", STC.out_),
            Parameter!(int, void, "ref_", STC.ref_),
            Parameter!(int, void, "lazy_", STC.lazy_),
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
            ReturnType!(modules.functions.voldemort),
            ReturnType!(modules.functions.voldemortArray),
            string,
        ),
    );
}
