module ut.meta.functions;


import ut.meta;
import std.meta: AliasSeq;


@("functions")
@safe pure unittest {
    alias mod = Module!("modules.functions");
    static import modules.functions;

    alias expected = AliasSeq!(
        modules.functions.add1,
        modules.functions.withDefault,
    );

    static assert(mod.Functions.length == expected.length, mod.Functions.stringof);
    static foreach(i; 0 .. expected.length) {
        static assert(__traits(isSame, mod.Functions[i], expected[i]), __traits(identifier, mod.Functions[i]));
    }
}
