module ut.meta.variables;


import ut.meta;
import std.meta: AliasSeq;


@("variables")
@safe pure unittest {
    static import modules.variables;

    alias mod = Module!("modules.variables");

    variables!mod.shouldBeSameSetAs(
        [
            VariableInfo("int", "gInt"),
            VariableInfo("double", "gDouble"),
            VariableInfo("Struct", "gStruct"),
        ]
    );

    static assert(is(mod.Variables[2].Type == modules.variables.Struct));
}


void shouldEqual(alias L, alias R)(in string file = __FILE__, in size_t line = __LINE__) {
    if(__traits(isSame, L, R))
        shouldEqual(L.stringof, R.stringof, file, line);
}


private struct VariableInfo {
    string type;
    string name;
}

private VariableInfo[] variables(alias module_)() {
    VariableInfo[] ret;

    static foreach(var; module_.Variables) {
        ret ~= VariableInfo(var.Type.stringof, var.name);
    }

    return ret;
}
