module ut.traits;


import ut;
import mirror.meta;
import mirror.traits;
import std.meta: AliasSeq;


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


@("FundamentalType.scalar")
@safe pure unittest {
    static assert(is(FundamentalType!int == int));
    static assert(is(FundamentalType!double == double));
    static struct Foo { }
    static assert(is(FundamentalType!Foo == Foo));
}


@("FundamentalType.array")
@safe pure unittest {
    static assert(is(FundamentalType!(int[]) == int));
    static assert(is(FundamentalType!(int[][]) == int));
    static assert(is(FundamentalType!(int[][][]) == int));

    static assert(is(FundamentalType!(double[]) == double));
    static assert(is(FundamentalType!(double[][]) == double));

    static assert(is(FundamentalType!string == immutable char));
    static assert(is(FundamentalType!(string[]) == immutable char));

    static struct Foo { }
    static assert(is(FundamentalType!(Foo[]) == Foo));
    static assert(is(FundamentalType!(Foo[][]) == Foo));
}


@("FundamentalType.pointer")
@safe pure unittest {
    static assert(is(FundamentalType!(int*) == int));
    static assert(is(FundamentalType!(int**) == int));
    static assert(is(FundamentalType!(int***) == int));

    static assert(is(FundamentalType!(double*) == double));
    static assert(is(FundamentalType!(double**) == double));

    static assert(is(FundamentalType!(string*) == immutable char));
    static assert(is(FundamentalType!(string**) == immutable char));

    static struct Foo { }
    static assert(is(FundamentalType!(Foo*) == Foo));
    static assert(is(FundamentalType!(Foo**) == Foo));
}


@("RecursiveFieldTypes.scalar")
@safe pure unittest {
    static assert(is(RecursiveFieldTypes!int == int));
    static assert(is(RecursiveFieldTypes!double == double));
}


@("RecursiveFieldTypes.udt.flat")
@safe pure unittest {

    static struct Foo {
        int i;
        double d;
    }

    shouldEqual!(RecursiveFieldTypes!Foo, AliasSeq!(int, double));
}


@("RecursiveAggregates.udt.nested")
@safe pure unittest {

    static struct Inner0 {
        int i;
        double d;
    }

    static struct Inner1 {
        double d;
        string s;
    }

    static struct Mid {
        Inner0 inner0;
        Inner1 inner1;
    }

    static struct Outer {
        Mid mid;
        byte b;
    }

    shouldEqual!(RecursiveFieldTypes!Outer,
                 AliasSeq!(Mid, Inner0, int, double, Inner1, string, byte));
}
