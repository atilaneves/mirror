module ut.meta.functions;


import ut.meta;
import std.meta: AliasSeq;
import std.conv: text;


@("functions")
@safe pure unittest {
    alias mod = Module!("modules.functions");
    import modules.functions;

    alias expected = AliasSeq!(
        Function!(modules.functions, add1)(Protection.public_, Linkage.D),
        Function!(modules.functions, withDefault)(Protection.public_, Linkage.D),
        Function!(modules.functions, storageClasses)(Protection.public_, Linkage.D),
        Function!(modules.functions, exportedFunc)(Protection.export_, Linkage.D),
        Function!(modules.functions, externC)(Protection.public_, Linkage.C),
        Function!(modules.functions, externCpp)(Protection.public_, Linkage.Cpp),
        Function!(modules.functions, identityInt, "identityInt")(Protection.public_, Linkage.D),
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

    const func = Function!(modules.functions, add1)();

    alias expected = AliasSeq!(
        Parameter!(int, void, "i"),
        Parameter!(int, void, "j"),
    );

    static assert(func.parameters.length == expected.length, func.parameters.length.text);

    static foreach(i; 0 .. expected.length) {
        static assert(__traits(isSame, func.parameters[i], expected[i]), func.parameters[i].stringof);
    }
}
