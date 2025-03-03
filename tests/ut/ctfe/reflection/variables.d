module ut.ctfe.reflection.variables;


import ut.ctfe.reflection;


@("variables")
@safe pure unittest {
    import std.conv: text;
    import std.algorithm: map;

    static immutable mod = module_!("modules.variables");
    mod.variables.map!(v => text(v.fullyQualifiedName, `: `, v.type.fullyQualifiedName)).should ~ [
        "modules.variables.gInt: int",
        "modules.variables.gDouble: immutable(double)",
        "modules.variables.gStruct: modules.variables.Struct",
        "modules.variables.CONSTANT_INT: int",
        "modules.variables.CONSTANT_STRING: string",
        "modules.variables.gImmutableInt: immutable(int)",
    ];
}
