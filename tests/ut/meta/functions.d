module ut.meta.functions;


import ut.meta;
import std.meta: AliasSeq;
import std.conv: text;


@("functions")
@safe pure unittest {
    alias mod = Module!("modules.functions");
    static import modules.functions;

    alias expected = AliasSeq!(
        Function!(__traits(getOverloads, modules.functions, "add1")[0])("add1", "public", "D"),
        Function!(__traits(getOverloads, modules.functions, "add1")[1])("add1", "public", "D"),
        Function!(modules.functions.withDefault)("withDefault", "public", "D"),
        Function!(modules.functions.storageClasses)("storageClasses", "public", "D"),
        Function!(modules.functions.exportedFunc)("exportedFunc", "export", "D"),
        Function!(modules.functions.externC)("externC", "public", "C"),
        Function!(modules.functions.externCpp)("externCpp", "public", "C++"),
        Function!(modules.functions.identityInt)("identityInt", "public", "D"),
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
}


@("problems")
@safe pure unittest {
    alias mod = Module!("modules.problems");
    static assert(mod.Functions.length == 0, mod.Functions.stringof);
}
