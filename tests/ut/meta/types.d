module ut.meta.types;


import ut.meta;


@("empty")
@safe pure unittest {
    alias mod = Module!"modules.imports";
    typeNames!mod.should == [];
}


@("imports")
@safe pure unittest {
    alias mod = Module!"modules.imports";
    typeNames!mod.should == [];
}


@("types")
@safe pure unittest {
    alias mod = Module!"modules.types";
    typeNames!mod.shouldBeSameSetAs(
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
    alias mod = Module!"modules.problems";
    typeNames!mod.should == [];
}


@("variables")
@safe pure unittest {
    alias mod = Module!"modules.variables";
    typeNames!mod.should == ["Struct"];
}


private string[] typeNames(alias module_)() {
    import std.meta: staticMap;
    enum name(alias Symbol) = __traits(identifier, Symbol);
    enum names = staticMap!(name, module_.Types);
    return [names];
}
