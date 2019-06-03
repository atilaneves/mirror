module ut.ctfe.types;


import ut.ctfe;


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
    import std.algorithm: map;
    enum mod = module_!"modules.types";
    mod.types.map!(a => a.name).shouldBeSameSetAs(["String", "Enum", "Class"]);
}


@("problems")
@safe pure unittest {
    import std.algorithm: map;
    enum mod = module_!"modules.problems";
    module_!"modules.empty".should == Module();
}
