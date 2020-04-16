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
    shouldEqual!(enums, AliasSeq!(modules.types.Enum, modules.types.Char));
}


@("isStruct")
@safe pure unittest {
    static import modules.types;
    import std.meta: Filter, AliasSeq;

    alias mod = Module!"modules.types";
    alias aggregates = mod.Aggregates;
    alias structs = Filter!(isStruct, aggregates);
    static assert(is(structs ==
                     AliasSeq!(
                         modules.types.String,
                         modules.types.Point,
                         modules.types.Inner1,
                         modules.types.EvenInner,
                         modules.types.Inner2,
                         modules.types.Outer,
                     )
                 ),
                  structs.stringof);
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


@("MemberFunctionsByOverload.struct")
@safe @nogc pure unittest {

    static struct Struct {
        private int _i;
        @property int i();
        @property void i(int i);
        int foo(double d);
        string bar(int i);
    }

    //pragma(msg, "MemberFunctionsByOverload.struct: ", MemberFunctionsByOverload!Struct.stringof);

    shouldEqual!(
        MemberFunctionsByOverload!Struct,
        AliasSeq!(
            __traits(getOverloads, Struct, "i")[0],
            __traits(getOverloads, Struct, "i")[1],
            Struct.foo,
            Struct.bar,
        )
    );
}


@("MemberFunctionsByOverload.class")
@safe @nogc pure unittest {

    static class Class {
        private int _i;
        @property int i() { return _i; }
        @property void i(int i) { _i = i; }
        int foo(double d) { return cast(int) (d * 2); }
        string bar(int i) { return "foobar"; }
    }

    //pragma(msg, "MemberFunctionsByOverload.class: ", MemberFunctionsByOverload!Class.stringof);

    shouldEqual!(
        MemberFunctionsByOverload!Class,
        AliasSeq!(
            __traits(getOverloads, Class, "i")[0],
            __traits(getOverloads, Class, "i")[1],
            Class.foo,
            Class.bar,
        )
    );
}


@("MemberFunctionsByOverload.std.stdio.File")
@safe @nogc pure unittest {
    import std.stdio: File;
    alias functions = MemberFunctionsByOverload!File;
    static assert(functions.length > 0);
}

@("MemberFunctionsByOverload.CtorProtectionsStruct")
@safe @nogc pure unittest {
    import modules.issues: CtorProtectionsStruct;
    alias functions = MemberFunctionsByOverload!CtorProtectionsStruct;
    pragma(msg, functions.stringof);
    static assert(functions.length == 1);  // the only public constructor
}


@("PublicMembers.std.socket")
@safe @nogc pure unittest {
    import std.socket;
    alias members = PublicMembers!(std.socket);
}



@("isStaticMemberFunction")
@safe @nogc pure unittest {
    static struct Struct {
        int foo();
        static int bar();
    }

    static void fun() {}

    static assert(!isStaticMemberFunction!(Struct.foo));
    static assert( isStaticMemberFunction!(Struct.bar));
    static assert(!isStaticMemberFunction!fun);
    static assert(!isStaticMemberFunction!staticGlobalFunc);
}


static void staticGlobalFunc() {

}


@("BinaryOperators")
@safe @nogc pure unittest {

    static struct Number {
        int i;
        Number opBinary(string op)(Number other) if(op == "+") {
            return Number(i + other.i);
        }
        Number opBinary(string op)(Number other) if(op == "-") {
            return Number(i - other.i);
        }
        Number opBinaryRight(string op)(int other) if(op == "+") {
            return Number(i + other);
        }
    }

    static assert(
        [BinaryOperators!Number] ==
        [
            BinaryOperator("+", BinOpDir.left | BinOpDir.right),
            BinaryOperator("-", BinOpDir.left),
        ]
    );
}


@("UnaryOperators")
@safe pure unittest {

    static struct Struct {
        int opUnary(string op)() if(op == "+") { return 42; }
        int opUnary(string op)() if(op == "~") { return 33; }
    }

    static assert([UnaryOperators!Struct] == ["+", "~"]);
}


@("AssignOperators")
@safe pure unittest {

    static struct Number {
        int i;
        Number opOpAssign(string op)(Number other) if(op == "+") {
            return Number(i + other.i);
        }
        Number opOpAssign(string op)(Number other) if(op == "-") {
            return Number(i - other.i);
        }
        Number opOpAssignRight(string op)(int other) if(op == "+") {
            return Number(i + other);
        }
    }

    static assert([AssignOperators!Number] == ["+", "-"]);
}


@("NumDefaultParameters")
@safe pure unittest {

    static void none0();
    static assert(NumDefaultParameters!none0 == 0);

    static void none1(int i);
    static assert(NumDefaultParameters!none1 == 0);

    static void one(int i, double d = 33.3);
    static assert(NumDefaultParameters!one == 1);

    static void two(int i, double d = 33.3, int j = 42);
    static assert(NumDefaultParameters!two == 2);
}


@("NumRequiredParameters")
@safe pure unittest {

    static void none();
    static assert(NumRequiredParameters!none == 0);

    static void one0(int i, double d = 33.3);
    static assert(NumRequiredParameters!one0 == 1);

    static void one1(int i, double d = 33.3, int j = 42);
    static assert(NumRequiredParameters!one1 == 1);

    static void two(int i, string s, double d = 33.3, int j = 42);
    static assert(NumRequiredParameters!two == 2);
}


@("Parameters.default.function.ptr")
@safe pure unittest {
    static string defaultFormatter(int) { return "oops"; }
    static void func(string function(int) @trusted errorFormatter = &defaultFormatter);
    alias params = Parameters!func;
}


@("isMutableSymbol")
@safe pure unittest {
    static import modules.variables;
    static assert( isMutableSymbol!(modules.variables.gInt));
    static assert(!isMutableSymbol!(modules.variables.gDouble));
    static assert( isMutableSymbol!(modules.variables.gStruct));
    static assert(!isMutableSymbol!(modules.variables.CONSTANT_INT));
    static assert(!isMutableSymbol!(modules.variables.CONSTANT_STRING));
    static assert(!isMutableSymbol!(modules.variables.gImmutableInt));
}


@("isVariable")
@safe pure unittest {
    static import modules.variables;
    import mirror.traits: MemberFromName;

    alias member(string name) = MemberFromName!(modules.variables, name);

    static assert( isVariable!(member!"gInt"));
    static assert(!isVariable!(member!"Struct"));
    static assert(!isVariable!(member!"templateFunction"));
}


@("Fields.struct.0")
@safe pure unittest {

    static struct Struct {
        int i;
        string s;
    }

    shouldEqual!(
        Fields!Struct,
        Field!(int, "i"), Field!(string, "s"),
    );
}


@("Fields.struct.1")
@safe pure unittest {

    static struct Struct {
        double d;
        byte b;
        string s;
    }

    shouldEqual!(
        Fields!Struct,
        Field!(double, "d"), Field!(byte, "b"), Field!(string, "s"),
    );
}
