module ut.ctfe.types;


import ut.ctfe;
import std.algorithm: map;


@("empty")
@safe pure unittest {
    module_!"modules.empty".should == Module();
}


@("imports")
@safe pure unittest {
    module_!"modules.imports".should == Module();
}


@("types")
@safe pure unittest {
    enum mod = module_!"modules.types";
    mod.types.map!(a => a.name).shouldBeSameSetAs(["String", "Enum", "Class"]);
}


@("problems")
@safe pure unittest {
    enum mod = module_!"modules.problems";
    module_!"modules.empty".should == Module();
}


@("variables")
@safe pure unittest {
    enum mod = module_!"modules.variables";
    mod.types.map!(a => a.name).shouldBeSameSetAs(["Struct"]);
}
