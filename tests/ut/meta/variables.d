module ut.meta.variables;


import ut.meta;
import std.meta: AliasSeq;


@("variables")
@safe pure unittest {
    static import modules.variables;

    alias mod = Module!("modules.variables");
    shouldEqual!(
        mod.Variables,
        AliasSeq!(
            Variable!(int, "gInt"),
            Variable!(double, "gDouble"),
            Variable!(modules.variables.Struct, "gStruct"),
            Variable!(int, "CONSTANT"),
            Variable!(immutable int, "gImmutableInt"),
        )
    );
}


@("problems")
@safe pure unittest {
    static import modules.variables;

    alias mod = Module!("modules.problems");
    static assert(mod.Variables.length == 0, mod.Variables.stringof);
}
