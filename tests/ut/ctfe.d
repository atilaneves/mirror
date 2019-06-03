module ut.ctfe;


import ut;


@("empty")
@safe pure unittest {
    module_!"modules.empty".should == Module();
}


@("types")
@safe pure unittest {
    import std.algorithm: map;
    enum mod = module_!"modules.types";
    mod.types.map!(a => a.name).should == ["String"];
}
