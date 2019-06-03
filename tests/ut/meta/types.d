module ut.meta.types;


import ut.meta;


@("types")
@safe pure unittest {
    import std.meta: staticMap;

    alias mod = Module!"modules.types";
    enum name(alias Symbol) = __traits(identifier, Symbol);
    enum names = staticMap!(name, mod.Types);
    [names].should == ["String"];
}
