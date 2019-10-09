module ut.traits;


import ut;
import mirror.meta;
import mirror.traits;


@("isEnum")
@safe pure unittest {
    static import modules.types;
    import std.meta: Filter, AliasSeq;

    alias mod = Module!"modules.types";
    alias aggregates = mod.Aggregates;
    alias enums = Filter!(isEnum, aggregates);
    static assert(is(enums == AliasSeq!(modules.types.Enum)), enums.stringof);
}


@("isStruct")
@safe pure unittest {
    static import modules.types;
    import std.meta: Filter, AliasSeq;

    alias mod = Module!"modules.types";
    alias aggregates = mod.Aggregates;
    alias structs = Filter!(isStruct, aggregates);
    static assert(is(structs == AliasSeq!(modules.types.String)), structs.stringof);
}


@("isInterface")
@safe pure unittest {
    static import modules.types;
    import std.meta: Filter, AliasSeq;

    alias mod = Module!"modules.types";
    alias aggregates = mod.Aggregates;
    alias interfaces = Filter!(isInterface, aggregates);
    static assert(is(interfaces == AliasSeq!(modules.types.Interface)), interfaces.stringof);
}


@("isClass")
@safe pure unittest {
    static import modules.types;
    import std.meta: Filter, AliasSeq;

    alias mod = Module!"modules.types";
    alias aggregates = mod.Aggregates;
    alias classes = Filter!(isClass, aggregates);
    alias expected = AliasSeq!(
        modules.types.Class,
        modules.types.AbstractClass,
        modules.types.MiddleClass,
        modules.types.LeafClass,
    );
    static assert(is(classes == expected), classes.stringof);
}


@("isOOP")
@safe pure unittest {
    static import modules.types;
    import std.meta: Filter, AliasSeq;

    alias mod = Module!"modules.types";
    alias aggregates = mod.Aggregates;
    alias classes = Filter!(isOOP, aggregates);
    alias expected = AliasSeq!(
        modules.types.Class,
        modules.types.Interface,
        modules.types.AbstractClass,
        modules.types.MiddleClass,
        modules.types.LeafClass,
    );
    static assert(is(classes == expected), classes.stringof);
}
