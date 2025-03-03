module ut.ctfe.reflection.types2;


import ut;
import mirror.ctfe.reflection2;


@("empty")
@safe pure unittest {
    module_!"modules.empty".should == Module("modules.empty");
}

@("imports")
@safe pure unittest {
    module_!"modules.imports".should == Module("modules.imports");
}

@("nameskinds")
@safe pure unittest {
    import std.algorithm: map;

    enum mod = module_!"modules.types";

    static struct NameAndKind {
        string id;
        Aggregate.Kind kind;
    }

    static NameAndKind xform(Aggregate a) {
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
    module_!"modules.problems".should ==
        Module(
            "modules.problems",
            [],
            [],
            [
                Aggregate(
                    "modules.problems.PrivateFields",
                    Aggregate.Kind.struct_,
                    [
                        Variable(Type("int"), "i"),
                        Variable(Type("string"), "s"),
                    ]
                ),
            ],
            [
                Aggregate(
                    "modules.problems.PrivateFields",
                    Aggregate.Kind.struct_,
                    [
                        Variable(Type("int"), "i"),
                        Variable(Type("string"), "s"),
                    ]
                ),
            ],
            [Variable(Type("int[]"), "modules.problems.gInts")],
        );
}


@("fields.String")
@safe pure unittest {
    enum mod = module_!"modules.types";
    auto string_ = mod.aggregates[0];
    string_.fields.should == [
        Variable(Type("string"), "value"),
    ];
}

@("fields.Point")
@safe pure unittest {
    import std.algorithm: find;
    enum mod = module_!"modules.types";
    auto point = mod.aggregates[].find!(a => a.fullyQualifiedName == "modules.types.Point")[0];
    point.fields.should == [
        Variable(Type("double"), "x"),
        Variable(Type("double"), "y"),
    ];
}


@("methods.String")
@safe pure unittest {
    import std.algorithm: find, map;
    enum mod = module_!"modules.types";
    enum str = mod.aggregates[].find!(a => a.fullyQualifiedName == "modules.types.String")[0];
    str.functionsByOverload.map!(a => a.identifier).should == ["withPrefix", "withPrefix"];

    enum withPrefix0Info = str.functionsByOverload[0];
    enum withPrefix1Info = str.functionsByOverload[1];
    mixin(withPrefix0Info.importMixin);

    alias withPrefix0 = mixin(withPrefix0Info.symbolMixin);
    static assert(is(typeof(&withPrefix0) == typeof(&__traits(getOverloads, modules.types.String, "withPrefix")[0])));

    alias withPrefix1 = mixin(withPrefix1Info.symbolMixin);
    static assert(is(typeof(&withPrefix1) == typeof(&__traits(getOverloads, modules.types.String, "withPrefix")[1])));

    str.functionsBySymbol.map!(a => a.identifier).should == ["withPrefix"];
    str.functionsBySymbol.length.should == 1;
}

@("methods.RussianDoll")
@safe pure unittest {
    import std.algorithm: find, map;
    enum mod = module_!"modules.types";
    enum str = mod.aggregates[].find!(a => a.fullyQualifiedName == "modules.types.RussianDoll")[0];
    // FIXME
    // need to recurse over inner defined types to get to the method.
}
