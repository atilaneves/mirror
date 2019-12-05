module ut.meta.variables;


import ut.meta;
import std.meta: AliasSeq;


@("variables")
@safe pure unittest {
    static import modules.variables;

    alias mod = Module!("modules.variables");
    static assert(__traits(isSame, mod.Variables[0], Variable!(int, "gInt", 0, false)));
    static assert(__traits(isSame, mod.Variables[3], Variable!(int, "CONSTANT_INT", 42, true)));
}


@("problems")
@safe pure unittest {
    static import modules.variables;

    alias mod = Module!("modules.problems");

    static assert(mod.Variables.length == 1, mod.Variables.stringof);

    shouldEqual!(
        mod.Variables,
        AliasSeq!(
            Variable!(int[], "gInts", (int[]).init, false),
        )
    );
}
