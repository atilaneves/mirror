module ut.ctfe.types;


import ut.ctfe;


@("empty")
@safe pure unittest {
    module_!"modules.empty".should == Module("modules.empty");
}


@("imports")
@safe pure unittest {
    module_!"modules.imports".should == Module("modules.imports");
}


@("types.nameskinds")
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
        NameAndKind("String", Aggregate.Kind.struct_),
        NameAndKind("Enum", Aggregate.Kind.enum_),
        NameAndKind("Class", Aggregate.Kind.class_),
        NameAndKind("Interface", Aggregate.Kind.interface_),
        NameAndKind("AbstractClass", Aggregate.Kind.class_),
        NameAndKind("MiddleClass", Aggregate.Kind.class_),
        NameAndKind("LeafClass", Aggregate.Kind.class_),
        NameAndKind("Point", Aggregate.Kind.struct_),
        NameAndKind("Inner1", Aggregate.Kind.struct_),
        NameAndKind("EvenInner", Aggregate.Kind.struct_),
        NameAndKind("Inner2", Aggregate.Kind.struct_),
        NameAndKind("Outer", Aggregate.Kind.struct_),
        NameAndKind("Char", Aggregate.Kind.enum_),
    ];

    mod.allAggregates.map!xform.should == [
        NameAndKind("String", Aggregate.Kind.struct_),
        NameAndKind("Enum", Aggregate.Kind.enum_),
        NameAndKind("Class", Aggregate.Kind.class_),
        NameAndKind("Interface", Aggregate.Kind.interface_),
        NameAndKind("AbstractClass", Aggregate.Kind.class_),
        NameAndKind("MiddleClass", Aggregate.Kind.class_),
        NameAndKind("LeafClass", Aggregate.Kind.class_),
        NameAndKind("Point", Aggregate.Kind.struct_),
        NameAndKind("Inner1", Aggregate.Kind.struct_),
        NameAndKind("EvenInner", Aggregate.Kind.struct_),
        NameAndKind("Inner2", Aggregate.Kind.struct_),
        NameAndKind("Outer", Aggregate.Kind.struct_),
        NameAndKind("Char", Aggregate.Kind.enum_),
    ];
}


@("problems")
@safe pure unittest {
    module_!"modules.problems".should ==
        Module(
            "modules.problems",
            [],
            [],
            [Variable("int[]", "gInts")],
            []
        );
}


@("variables")
@safe pure unittest {
    enum mod = module_!"modules.variables";
    auto aggs = mod.aggregates[];
    aggs.length.should == 1;
    aggs[0].identifier.should == "Struct";
    aggs[0].kind.should == Aggregate.Kind.struct_;
}


@("types.fields.String")
@safe pure unittest {
    enum mod = module_!"modules.types";
    immutable string_ = mod.aggregates[0];
    string_.fields.length.should == 1;
}
