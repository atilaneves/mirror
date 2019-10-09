module ut.meta.functions;


import ut.meta;
import std.meta: AliasSeq;
import std.conv: text;


@("functions")
@safe pure unittest {
    alias mod = Module!("modules.functions");
    import modules.functions;

    alias expected = AliasSeq!(
        Function!(add1)(Protection.public_, Linkage.D),
        Function!(withDefault)(Protection.public_, Linkage.D),
        Function!(storageClasses)(Protection.public_, Linkage.D),
        Function!(exportedFunc)(Protection.export_, Linkage.D),
        Function!(externC)(Protection.public_, Linkage.C),
        Function!(externCpp)(Protection.public_, Linkage.Cpp),
        Function!(identityInt, "identityInt", modules.functions)(Protection.public_, Linkage.D),
    );

    static assert(mod.Functions.length == expected.length, mod.Functions.stringof);

    static foreach(i; 0 .. expected.length) {
        static assert(__traits(isSame, mod.Functions[i].symbol, expected[i].symbol),
                      __traits(identifier, mod.Functions[i]));
        static assert(mod.Functions[i].protection == expected[i].protection,
                      text(mod.Functions[i].stringof, " is not ", expected[i].protection));
        static assert(mod.Functions[i].linkage == expected[i].linkage,
                      text(mod.Functions[i].stringof, " is not ", expected[i].linkage));
    }

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

    enum func = Function!add1();
    alias parameters = AliasSeq!(func.parameters);

    alias expected = AliasSeq!(
        Parameter!(int, void, "i"),
        Parameter!(int, void, "j"),
    );

    static assert(parameters.length == expected.length, parameters.length.text);

    static foreach(i; 0 .. expected.length) {
        static assert(__traits(isSame, parameters[i], expected[i]), parameters[i].stringof);
    }
}
