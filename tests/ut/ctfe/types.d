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
    mod.aggregates.should == [
        Aggregate("String"),
        Aggregate("Enum"),
        Aggregate("Class"),
        Aggregate("Interface"),
        Aggregate("AbstractClass"),
        Aggregate("MiddleClass"),
        Aggregate("LeafClass"),
    ];
}


@("problems")
@safe pure unittest {
    module_!"modules.problems".should == Module("modules.problems");
}


@("variables")
@safe pure unittest {
    enum mod = module_!"modules.variables";
    mod.aggregates.should == [
        Aggregate("Struct")
    ];
}
