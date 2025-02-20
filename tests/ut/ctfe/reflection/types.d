module ut.ctfe.reflection.types;


import ut.ctfe.reflection;


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
        return NameAndKind(a.identifier, a.kind);
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
            [
                Aggregate(
                    "modules.problems.PrivateFields",
                    Aggregate.Kind.struct_,
                    [
                        Variable("int", "i"),
                        Variable("string", "s"),
                    ]
                ),
            ],
            [
                Aggregate(
                    "modules.problems.PrivateFields",
                    Aggregate.Kind.struct_,
                    [
                        Variable("int", "i"),
                        Variable("string", "s"),
                    ]
                ),
            ],
            [Variable("int[]", "gInts")],
            []
        );
}


@("variables")
@safe pure unittest {
    enum mod = module_!"modules.variables";
    auto aggs = mod.aggregates[];
    aggs.length.should == 1;
    aggs[0].identifier.should == "modules.variables.Struct";
    aggs[0].kind.should == Aggregate.Kind.struct_;
}


@("fields.String")
@safe pure unittest {
    enum mod = module_!"modules.types";
    auto string_ = mod.aggregates[0];
    string_.fields.should == [
        Variable("string", "value"),
    ];
}


@("fields.Point")
@safe pure unittest {
    import std.algorithm: find;
    enum mod = module_!"modules.types";
    auto point = mod.aggregates[].find!(a => a.identifier == "modules.types.Point")[0];
    point.fields.should == [
        Variable("double", "x"),
        Variable("double", "y"),
    ];
}

@("methods")
@safe pure unittest {
    import std.algorithm: find;
    enum mod = module_!"modules.types";
    const str = mod.aggregates[].find!(a => a.identifier == "modules.types.String")[0];
    str.functionsByOverload.length.should == 2;
    str.functionsBySymbol.length.should == 1;
}
