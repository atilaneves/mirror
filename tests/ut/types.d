module ut.types;


import ut;


@("types")
@safe pure unittest {
    import std.algorithm: map;
    enum mod = module_!"modules.types";
    mod.types.map!(a => a.name).should == ["String"];
}
