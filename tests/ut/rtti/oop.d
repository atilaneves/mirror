module ut.rtti.oop;


import ut;
import mirror.rtti;


@("name")
@safe pure unittest {

    static abstract class Abstract {
        string getName() @safe pure nothrow scope const;
    }

    static class Foo: Abstract {
        override string getName() @safe pure nothrow scope const {
            return "Foo";
        }
    }

    static class Bar: Abstract {
        override string getName() @safe pure nothrow scope const {
            return "Bar";
        }
    }

    // explicit Abstract and not auto so as to erase the type
    // of the value
    const Abstract foo = new Foo();
    const Abstract bar = new Bar();

    with(types!(Foo, Bar)) {
        const fooType = rtti(foo);
        const barType = rtti(bar);

        enum testId = __traits(identifier, __traits(parent, {}));
        enum prefix = __MODULE__ ~ "." ~ testId ~ ".";

        fooType.name.should == prefix ~ "Foo";
        barType.name.should == prefix ~ "Bar";
    }
}


@("typeInfo")
// The test is neither @safe nor pure because Object.opEquals isn't
@system unittest {

    static abstract class Abstract { }
    static class Class: Abstract { }
    const Abstract obj = new Class();

    with(types!Class) {
        auto type = rtti(obj);
        type.typeInfo.should.not == typeid(int);
        type.typeInfo.should.not == typeid(Abstract);
        type.typeInfo.should == typeid(Class);
    }
}


@("fields.typeInfo.0")
@system unittest {
    import std.algorithm: map;
    import std.array: array;

    static abstract class Abstract {}
    static class Class: Abstract {
        int i;
        string s;
    }
    const Abstract obj = new Class;

    with(types!Class) {
        const type = rtti(obj);
        type.fields.map!(a => a.typeInfo).array.should == [
            typeid(int),
            typeid(string),
        ];
    }
}


@("fields.type.0")
@safe pure unittest {
    import std.algorithm: map;

    static abstract class Abstract {}
    static class Class: Abstract {
        int i;
        string s;
    }
    const Abstract obj = new Class;

    with(types!Class) {
        const type = rtti(obj);
        type.fields.map!(a => a.type).should == [ "int", "string" ];
    }
}


@("fields.id.0")
@safe pure unittest {
    import std.algorithm: map;

    static abstract class Abstract {}
    static class Class: Abstract {
        int i;
        string s;
    }
    const Abstract obj = new Class;

    with(types!Class) {
        const type = rtti(obj);
        type.fields.map!(a => a.identifier).should == [ "i", "s" ];
    }
}


@("fields.get.0")
@system /* typeInfo */ unittest {

    static abstract class Abstract {}
    static class Class: Abstract {
        int i;
        string s;
        this(int i, string s) { this.i = i; this.s = s; }
    }
    const Abstract obj = new Class(42, "foobar");

    with(types!Class) {
        const type = rtti(obj);

        type.fields[0].get!int(obj).should == 42;
        type.fields[0].get!string(obj).shouldThrow;

        type.fields[1].get!int(obj).shouldThrow;
        type.fields[1].get!string(obj).should == "foobar";
    }
}


@("fields.typeInfo.1")
@system unittest {

    import std.algorithm: map;
    import std.array: array;

    static abstract class Abstract {}
    static class Class: Abstract {
        string s0;
        string s1;
        double d;
        string s2;
    }
    const Abstract obj = new Class();

    with(types!Class) {
        const type = rtti(obj);
        type.fields.map!(a => a.typeInfo).array.should == [
            typeid(string),
            typeid(string),
            typeid(double),
            typeid(string),
        ];
    }
}


@("fields.type.1")
@safe pure unittest {

    import std.algorithm: map;

    static abstract class Abstract {}
    static class Class: Abstract {
        string s0;
        string s1;
        double d;
        string s2;
    }
    const Abstract obj = new Class();

    with(types!Class) {
        const type = rtti(obj);
        type.fields.map!(a => a.type).should == [
            "string",
            "string",
            "double",
            "string",
        ];
    }
}


@("fields.id.1")
@safe pure unittest {

    import std.algorithm: map;

    static abstract class Abstract {}
    static class Class: Abstract {
        string s0;
        string s1;
        double d;
        string s2;
    }
    const Abstract obj = new Class();

    with(types!Class) {
        const type = rtti(obj);
        type.fields.map!(a => a.identifier).should == [
            "s0",
            "s1",
            "d",
            "s2",
        ];
    }
}

@("fields.get.1")
@safe unittest {

    import std.algorithm: map;

    static abstract class Abstract {}
    static class Class: Abstract {
        string s0;
        private string s1;
        double d;
        string s2;
        this(string s0, double d, string s2) {
            this.s0 = s0;
            this.s1 = "nope";
            this.d = d;
            this.s2 = s2;
        }
    }
    const Abstract obj = new Class("quux", 33.3, "toto");

    with(types!Class) {
        const type = rtti(obj);

        type.fields[0].get!string(obj).should == "quux";
        type.fields[1].get!string(obj).shouldThrowWithMessage("Cannot get private member");
        type.fields[2].toString(obj).should == "33.3";
    }
}


@("field.get")
@safe unittest {
    static class Class {
        int i;
        double d;
        this(int i, double d) { this.i = i; this.d = d; }
    }

    const Object obj = new Class(42, 33.3);

    with(types!Class) {
        const type = rtti(obj);

        type.field("i").get!int(obj).should == 42;
        type.field("i").get!string(obj).shouldThrow;

        type.field("d").get!double(obj).should == 33.3;
        type.field("d").get!string(obj).shouldThrow;

        type.field("foo").shouldThrowWithMessage("No field named 'foo'");
        type.field("bar").shouldThrowWithMessage("No field named 'bar'");
    }
}


@("field.set")
@safe unittest {
    static class Class {
        int i;
        double d;
        this(int i, double d) { this.i = i; this.d = d; }
    }

    Object obj = new Class(42, 33.3);

    with(types!Class) {
        const type = rtti(obj);
        type.field("i").get!int(obj).should == 42;

        type.field("i").set(obj, 77);
        type.field("i").get!int(obj).should == 77;
    }
}


@("toString.Int")
@safe pure unittest {

    static class Int {
        int i;
        this(int i) { this.i = i; }

        override string toString() @safe pure scope const {
            import std.conv: text;
            return text(`Int(`, i, `)`);
        }
    }

    static class Double {
        double d;
        this(double d) { this.d = d; }
    }

    with(types!Int) {
        const type = rtti!Int;
        type.toString(new Int(42)).should == "Int(42)";
        type.toString(new Int(88)).should == "Int(88)";

        enum testName = __traits(identifier, __traits(parent, {}));
        enum prefix = __MODULE__ ~ "." ~ testName ~ ".";
        type.toString(new Double(33.3)).shouldThrowWithMessage(
            "Cannot call toString on obj since not of type " ~ prefix ~ "Int");
    }
}


@("methods.toString")
@safe pure unittest {

    import std.algorithm.iteration: map;

    static class Arithmetic {
        int i;
        this(int i) { this.i = i; }
        int add(int j) const { return i + j; }
        int mul(int j) const { return i * j; }
        double toDouble() const { return i; }
    }

    const Object obj = new Arithmetic(3);

    with(types!Arithmetic) {
        const type = rtti(obj);
        type.methods.map!(a => a.toString).should == [
            "int add(int)",
            "int mul(int)",
            "double toDouble()",
        ];
    }
}


@("methods.byName")
@safe pure unittest {

    static class Class {
        void foo() {}
        void bar() {}
    }

    const Object obj = new Class;

    with(types!Class) {
        const type = rtti(obj);

        const foo = type.method("foo");
        assert(foo is type.methods[0]);

        const bar = type.method("bar");
        assert(bar is type.methods[1]);

        type.method("baz").shouldThrowWithMessage(`No method named 'baz'`);
    }
}
