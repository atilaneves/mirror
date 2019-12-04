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


@("types")
@safe pure unittest {
    enum mod = module_!"modules.types";

    mod.aggregates[].should == [
        Aggregate("String", Aggregate.Kind.struct_),
        Aggregate("Enum", Aggregate.Kind.enum_),
        Aggregate("Class", Aggregate.Kind.class_),
        Aggregate("Interface", Aggregate.Kind.interface_),
        Aggregate("AbstractClass", Aggregate.Kind.class_),
        Aggregate("MiddleClass", Aggregate.Kind.class_),
        Aggregate("LeafClass", Aggregate.Kind.class_),
        Aggregate("Point", Aggregate.Kind.struct_),
        Aggregate("Inner1", Aggregate.Kind.struct_),
        Aggregate("EvenInner", Aggregate.Kind.struct_),
        Aggregate("Inner2", Aggregate.Kind.struct_),
        Aggregate("Outer", Aggregate.Kind.struct_),
        Aggregate("Char", Aggregate.Kind.enum_),
    ];

    mod.allAggregates[].should == [
        Aggregate("String", Aggregate.Kind.struct_),
        Aggregate("Enum", Aggregate.Kind.enum_),
        Aggregate("Class", Aggregate.Kind.class_),
        Aggregate("Interface", Aggregate.Kind.interface_),
        Aggregate("AbstractClass", Aggregate.Kind.class_),
        Aggregate("MiddleClass", Aggregate.Kind.class_),
        Aggregate("LeafClass", Aggregate.Kind.class_),
        Aggregate("Point", Aggregate.Kind.struct_),
        Aggregate("Inner1", Aggregate.Kind.struct_),
        Aggregate("EvenInner", Aggregate.Kind.struct_),
        Aggregate("Inner2", Aggregate.Kind.struct_),
        Aggregate("Outer", Aggregate.Kind.struct_),
        Aggregate("Char", Aggregate.Kind.enum_),
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
    mod.aggregates[].should == [
        Aggregate("Struct", Aggregate.Kind.struct_),
    ];
}
