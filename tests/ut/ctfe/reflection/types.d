module ut.ctfe.reflection.types;


import ut.ctfe.reflection;


@("empty")
@safe pure unittest {
    module_!"modules.empty".aggregates.length.should == 0;
}

@("imports")
@safe pure unittest {
    module_!"modules.imports".aggregates.length.should == 0;
}

@("nameskinds")
@safe pure unittest {
    import std.algorithm: map;

    static immutable mod = module_!"modules.types";

    static struct NameAndKind {
        string id;
        Aggregate.Kind kind;
    }

    static NameAndKind xform(in Aggregate a) {
        return NameAndKind(a.fullyQualifiedName, a.kind);
    }

    mod.aggregates.map!xform.should == [
        NameAndKind("modules.types.String", Aggregate.Kind.struct_),
        NameAndKind("modules.types.Enum", Aggregate.Kind.enum_),
        NameAndKind("modules.types.Class", Aggregate.Kind.class_),
        NameAndKind("modules.types.Interface", Aggregate.Kind.interface_),
        NameAndKind("modules.types.AbstractClass", Aggregate.Kind.class_),
        NameAndKind("modules.types.MiddleClass", Aggregate.Kind.class_),
        NameAndKind("modules.types.LeafClass", Aggregate.Kind.class_),
        NameAndKind("modules.types.Point", Aggregate.Kind.struct_),
        NameAndKind("modules.types.Inner1", Aggregate.Kind.struct_),
        NameAndKind("modules.types.EvenInner", Aggregate.Kind.struct_),
        NameAndKind("modules.types.Inner2", Aggregate.Kind.struct_),
        NameAndKind("modules.types.Outer", Aggregate.Kind.struct_),
        NameAndKind("modules.types.Char", Aggregate.Kind.enum_),
        NameAndKind("modules.types.Union", Aggregate.Kind.union_),
        NameAndKind("modules.types.RussianDoll", Aggregate.Kind.struct_),
    ];

    mod.allAggregates.map!xform.should == [
        NameAndKind("modules.types.String", Aggregate.Kind.struct_),
        NameAndKind("modules.types.Enum", Aggregate.Kind.enum_),
        NameAndKind("modules.types.Class", Aggregate.Kind.class_),
        NameAndKind("modules.types.Interface", Aggregate.Kind.interface_),
        NameAndKind("modules.types.AbstractClass", Aggregate.Kind.class_),
        NameAndKind("modules.types.MiddleClass", Aggregate.Kind.class_),
        NameAndKind("modules.types.LeafClass", Aggregate.Kind.class_),
        NameAndKind("modules.types.Point", Aggregate.Kind.struct_),
        NameAndKind("modules.types.Inner1", Aggregate.Kind.struct_),
        NameAndKind("modules.types.EvenInner", Aggregate.Kind.struct_),
        NameAndKind("modules.types.Inner2", Aggregate.Kind.struct_),
        NameAndKind("modules.types.Outer", Aggregate.Kind.struct_),
        NameAndKind("modules.types.Char", Aggregate.Kind.enum_),
        NameAndKind("modules.types.Union", Aggregate.Kind.union_),
        NameAndKind("modules.types.RussianDoll", Aggregate.Kind.struct_),
    ];
}

@("problems")
@safe pure unittest {
    import std.array: front;
    import std.algorithm: find;

    static immutable mod = module_!"modules.problems";

    auto actual = mod.aggregates.find!(a => a.identifier == "PrivateFields")[0];
    actual.fullyQualifiedName.should == "modules.problems.PrivateFields";
    actual.kind.should == Aggregate.Kind.struct_;
    actual.variables.should == [
        Variable(Type("int"), "modules.problems.PrivateFields.i"),
        Variable(Type("string"), "modules.problems.PrivateFields.s"),
    ];
}


@("fields.String")
@safe pure unittest {
    static immutable mod = module_!"modules.types";
    auto string_ = mod.aggregates[0];
    string_.variables.should == [
        Variable(Type("string"), "modules.types.String.value"),
    ];
}

@("fields.Point")
@safe pure unittest {
    import std.algorithm: find;
    static immutable mod = module_!"modules.types";
    auto point = mod.aggregates[].find!(a => a.fullyQualifiedName == "modules.types.Point")[0];
    point.variables.should == [
        Variable(Type("double"), "modules.types.Point.x"),
        Variable(Type("double"), "modules.types.Point.y"),
    ];
}


@("methods.String")
@safe pure unittest {
    import std.algorithm: find, map;
    static immutable mod = module_!"modules.types";
    static immutable str = mod.aggregates[].find!(a => a.fullyQualifiedName == "modules.types.String")[0];
    str.functionsByOverload.map!(a => a.identifier).should == ["withPrefix", "withPrefix"];

    enum withPrefix0Info = str.functionsByOverload[0];
    enum withPrefix1Info = str.functionsByOverload[1];
    mixin(withPrefix0Info.importMixin);

    alias withPrefix0 = mixin(withPrefix0Info.aliasMixin);
    static assert(is(typeof(&withPrefix0) == typeof(&__traits(getOverloads, modules.types.String, "withPrefix")[0])));

    alias withPrefix1 = mixin(withPrefix1Info.aliasMixin);
    static assert(is(typeof(&withPrefix1) == typeof(&__traits(getOverloads, modules.types.String, "withPrefix")[1])));

    str.functionsBySymbol.map!(a => a.identifier).should == ["withPrefix"];
    str.functionsBySymbol.length.should == 1;
}

@("methods.RussianDoll")
@safe pure unittest {
    import std.algorithm: find, map;
    static immutable mod = module_!"modules.types";
    static immutable info = mod.aggregates[].find!(a => a.fullyQualifiedName == "modules.types.RussianDoll")[0];
    static import modules.types;
    alias T = mixin(info.aliasMixin);
    static assert(is(T == modules.types.RussianDoll));
    // FIXME
    // need to recurse over inner defined types to get to the method.
}
