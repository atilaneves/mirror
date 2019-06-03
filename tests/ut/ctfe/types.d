module ut.ctfe.types;


import ut.ctfe;
import std.algorithm: map;


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
    mod.types.map!(a => a.name).shouldBeSameSetAs(
        [
            "String",
            "Enum",
            "Class",
            "Interface",
            "AbstractClass",
            "MiddleClass",
            "LeafClass",
        ]
    );
}


@("problems")
@safe pure unittest {
    module_!"modules.problems".should == Module("modules.problems");
}


@("variables")
@safe pure unittest {
    enum mod = module_!"modules.variables";
    mod.types.map!(a => a.name).shouldBeSameSetAs(["Struct"]);
}
