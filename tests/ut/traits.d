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


@("RecursiveFieldTypes.udt.nested")
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
        float func(float, float);

        @property static Outer max() @safe pure nothrow @nogc {
            return Outer();
        }
    }

    shouldEqual!(RecursiveFieldTypes!Outer,
                 AliasSeq!(Mid, Inner0, int, double, Inner1, string, byte));
}


@("RecursiveFieldTypes.udt.Date")
@safe pure unittest {

    import std.datetime: Date, Month;

    static struct Struct {
        int i;
        Date date;
    }

    shouldEqual!(RecursiveFieldTypes!Struct,
                 AliasSeq!(int, Date, short, Month, ubyte));
}


@("RecursiveFieldTypes.udt.DateTime")
@safe pure unittest {

    import std.datetime: Date, DateTime, Month, TimeOfDay;

    static struct Struct {
        int i;
        DateTime date;
    }

    shouldEqual!(RecursiveFieldTypes!Struct,
                 AliasSeq!(int, DateTime, Date, short, Month, ubyte, TimeOfDay));
}


@("RecursiveFieldTypes.udt.composite.struct")
@safe pure unittest {

    static struct Struct {
        Struct* child;
    }

    shouldEqual!(RecursiveFieldTypes!Struct, Struct*);
}


@("RecursiveFieldTypes.udt.composite.class.simple")
@safe pure unittest {

    static class Class {
        Class child;
    }

    shouldEqual!(RecursiveFieldTypes!Class, Class);
}


@("RecursiveFieldTypes.udt.composite.class.multiple")
@safe pure unittest {

    shouldEqual!(RecursiveFieldTypes!RecursiveClass0,
                 AliasSeq!(RecursiveClass1, RecursiveClass2));
}


private class RecursiveClass0 {
    RecursiveClass1 child;
}

private class RecursiveClass1 {
    RecursiveClass2 child;
}

private class RecursiveClass2 {
    RecursiveClass0 child;
}


@("RecursiveFieldTypes.udt.composite.array")
@safe pure unittest {

    static struct Point(T) {
        T x, y;
    }

    struct Inner1(T) {
        Point!T point;
        T value;
    }

    struct EvenInner(T) {
        T value;
    }

    struct Inner2(T) {
        EvenInner!T evenInner;
    }

    static struct Outer(T) {
        Inner1!T[] inner1s;
        Inner2!T inner2;
    }

    // pragma(msg, RecursiveFieldTypes!(Outer!double));
    shouldEqual!(RecursiveFieldTypes!(Outer!double),
                 AliasSeq!(Inner1!double[], Point!double, double, Inner2!double, EvenInner!double));
}


@("RecursiveFieldTypes.SocketOSException")
@safe @nogc pure unittest {
    import std.socket: SocketOSException;
    alias types = RecursiveFieldTypes!SocketOSException;
    //pragma(msg, types);
    shouldEqual!(types, AliasSeq!int);
}


@("isProperty.struct")
@safe @nogc pure unittest {

    static struct Struct {
        int _i;
        @property int i();
        @property void i(int i);
        int foo(double d);
    }

    static assert(isProperty!(__traits(getOverloads, Struct, "i")[1]));
    static assert(isProperty!(__traits(getOverloads, Struct, "i")[1]));
    static assert(!isProperty!(Struct.foo));
}


@("isProperty.class")
@safe @nogc pure unittest {

    static class Class {
        int _i;
        @property int i() { return _i; }
        @property void i(int i) { _i = i; }
        int foo(double d) { return i * 2; }
    }

    static assert(isProperty!(__traits(getOverloads, Class, "i")[1]));
    static assert(isProperty!(__traits(getOverloads, Class, "i")[1]));
    static assert(!isProperty!(Class.foo));
}


@("MemberFunctions.struct")
@safe @nogc pure unittest {

    static struct Struct {
        private int _i;
        @property int i();
        @property void i(int i);
        int foo(double d);
        string bar(int i);
    }

    //pragma(msg, "MemberFunctions.struct: ", MemberFunctions!Struct.stringof);

    shouldEqual!(
        MemberFunctions!Struct,
        AliasSeq!(
            __traits(getOverloads, Struct, "i")[0],
            __traits(getOverloads, Struct, "i")[1],
            Struct.foo,
            Struct.bar,
        )
    );
}


@("MemberFunctions.class")
@safe @nogc pure unittest {

    static class Class {
        private int _i;
        @property int i() { return _i; }
        @property void i(int i) { _i = i; }
        int foo(double d) { return cast(int) (d * 2); }
        string bar(int i) { return "foobar"; }
    }

    //pragma(msg, "MemberFunctions.class: ", MemberFunctions!Class.stringof);

    shouldEqual!(
        MemberFunctions!Class,
        AliasSeq!(
            __traits(getOverloads, Class, "i")[0],
            __traits(getOverloads, Class, "i")[1],
            Class.foo,
            Class.bar,
        )
    );
}


@("PublicMembers.std.socket")
@safe @nogc pure unittest {
    import std.socket;
    alias members = PublicMembers!(std.socket);
}
