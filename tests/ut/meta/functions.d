module ut.meta.functions;


import ut.meta;
import std.meta: AliasSeq;


@("functions")
@safe pure unittest {
    alias mod = Module!("modules.functions");
    static import modules.functions;

    alias expected = AliasSeq!(
        __traits(getOverloads, modules.functions, "add1")[0],
        __traits(getOverloads, modules.functions, "add1")[1],
        modules.functions.withDefault,
        modules.functions.storageClasses,
    );

    static foreach(i; 0 .. expected.length) {
        static assert(__traits(isSame, mod.Functions[i].symbol, expected[i]),
                      __traits(identifier, mod.Functions[i]));
    }
}


@("problems")
@safe pure unittest {
    alias mod = Module!("modules.problems");
    static assert(mod.Functions.length == 0, mod.Functions.stringof);
}
