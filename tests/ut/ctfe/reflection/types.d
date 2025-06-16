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
    import std.conv: text;
    import std.algorithm: find, map;

    static immutable mod = module_!"modules.problems";

    auto actual = mod.aggregates.find!(a => a.identifier == "PrivateFields")[0];
    actual.fullyQualifiedName.should == "modules.problems.PrivateFields";
    actual.kind.should == Aggregate.Kind.struct_;
    actual.variables.map!(v => text(v.fullyQualifiedName, `: `, v.type.fullyQualifiedName)).should == [
        "modules.problems.PrivateFields.i: int",
        "modules.problems.PrivateFields.s: string",
    ];

    actual.variables[0].visibility.should == Visibility.private_;
    actual.variables[1].visibility.should == Visibility.public_;
}


@("fields.String")
@safe pure unittest {
    import std.conv: text;
    import std.algorithm: map;

    static immutable mod = module_!"modules.types";
    auto string_ = mod.aggregates[0];

    string_.variables.map!(v => text(v.fullyQualifiedName, `: `, v.type.fullyQualifiedName)).should == [
        "modules.types.String.value: string",
    ];

    string_.variables[0].visibility.should == Visibility.public_;
}

@("fields.Point")
@safe pure unittest {
    import std.algorithm: find, map;
    import std.conv: text;

    static immutable mod = module_!"modules.types";
    auto point = mod.aggregates[].find!(a => a.fullyQualifiedName == "modules.types.Point")[0];
    point.variables.map!(v => text(v.fullyQualifiedName, `: `, v.type.fullyQualifiedName)).should == [
        "modules.types.Point.x: double",
        "modules.types.Point.y: double",
    ];
}


@("methods.String")
@safe pure unittest {
    import std.algorithm: find, map;
    import std.array: array;

    static immutable mod = module_!"modules.types";
    static immutable str = mod.aggregates[].find!(a => a.fullyQualifiedName == "modules.types.String")[0];
    str.functionsByOverload.map!(a => a.identifier).array.should == ["withPrefix", "withPrefix"];

    static immutable withPrefix0Info = str.functionsByOverload[0];
    static immutable withPrefix1Info = str.functionsByOverload[1];
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

@("methods.call.variant")
@safe unittest {
    import std.algorithm: find;
    import std.variant: Variant;
    static import modules.types;

    const mod = module_!"modules.types";
    const info = mod.aggregates[].find!(a => a.fullyQualifiedName == "modules.types.String")[0];
    const withPrefix0 = info.functionsByOverload[0];
    const withPrefix1 = info.functionsByOverload[1];

    auto str = modules.types.String("foo");
    () @trusted {
        withPrefix0(&str).get!string.should == "pre_foo";
        withPrefix1(&str, [Variant("quux")]).get!string.should == "quuxfoo";
    }();
}

@("methods.call.variant")
@safe unittest {
    import std.algorithm: find;
    import std.variant: Variant;
    static import modules.types;

    const mod = module_!"modules.types";
    const info = mod.aggregates[].find!(a => a.fullyQualifiedName == "modules.types.String")[0];
    const withPrefix0 = info.functionsByOverload[0];
    const withPrefix1 = info.functionsByOverload[1];

    auto str = modules.types.String("foo");
    () @trusted {
        withPrefix0(&str).get!string.should == "pre_foo";
        withPrefix1(&str, [Variant("quux")]).get!string.should == "quuxfoo";
    }();
}

@("methods.call.template")
@safe unittest {
    import std.algorithm: find;
    import std.variant: Variant;
    static import modules.types;

    const mod = module_!"modules.types";
    const info = mod.aggregates[].find!(a => a.fullyQualifiedName == "modules.types.String")[0];
    const withPrefix0 = info.functionsByOverload[0];
    const withPrefix1 = info.functionsByOverload[1];

    auto str = modules.types.String("foo");
    () @trusted {
        withPrefix0.methodCall!string(&str).should == "pre_foo";
        withPrefix1.methodCall!string(&str, "quux").should == "quuxfoo";
    }();
}
