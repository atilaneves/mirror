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

    with(extendRTTI!(Foo, Bar)) {
        const fooInfo = rtti(foo);
        const barInfo = rtti(bar);

        fooInfo.name.should == "Foo";
        barInfo.name.should == "Bar";

        enum testId = __traits(identifier, __traits(parent, {}));
        fooInfo.fullyQualifiedName.should == __MODULE__ ~ "." ~ testId ~ ".Foo";
        barInfo.fullyQualifiedName.should == __MODULE__ ~ "." ~ testId ~ ".Bar";
    }
}


@("typeInfo")
// The test is neither @safe nor pure because Object.opEquals isn't
@system unittest {

    static abstract class Abstract { }
    static class Class: Abstract { }
    const Abstract obj = new Class();

    with(extendRTTI!Class) {
        auto info = rtti(obj);
        info.typeInfo.should.not == typeid(int);
        info.typeInfo.should.not == typeid(Abstract);
        info.typeInfo.should == typeid(Class);
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
        this(int i, string s) { this.i = i; this.s = s; }
    }
    const Abstract obj = new Class(42, "foobar");

    with(extendRTTI!Class) {
        const info = rtti(obj);
        info.fields.map!(a => a.typeInfo).array.should == [
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
        this(int i, string s) { this.i = i; this.s = s; }
    }
    const Abstract obj = new Class(42, "foobar");

    with(extendRTTI!Class) {
        const info = rtti(obj);
        info.fields.map!(a => a.type).should == [ "int", "string" ];
    }
}

@("fields.id.0")
@safe pure unittest {
    import std.algorithm: map;

    static abstract class Abstract {}
    static class Class: Abstract {
        int i;
        string s;
        this(int i, string s) { this.i = i; this.s = s; }
    }
    const Abstract obj = new Class(42, "foobar");

    with(extendRTTI!Class) {
        const info = rtti(obj);
        info.fields.map!(a => a.identifier).should == [ "i", "s" ];
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

    with(extendRTTI!Class) {
        const info = rtti(obj);

        info.fields[0].get!int(obj).should == 42;
        info.fields[0].get!string(obj).shouldThrow;

        info.fields[1].get!int(obj).shouldThrow;
        info.fields[1].get!string(obj).should == "foobar";
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

    with(extendRTTI!Class) {
        const info = rtti(obj);
        info.fields.map!(a => a.typeInfo).array.should == [
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

    with(extendRTTI!Class) {
        const info = rtti(obj);
        info.fields.map!(a => a.type).should == [
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

    with(extendRTTI!Class) {
        const info = rtti(obj);
        info.fields.map!(a => a.identifier).should == [
            "s0",
            "s1",
            "d",
            "s2",
        ];
    }
}

@("fields.get.1")
@system unittest {

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

    with(extendRTTI!Class) {
        const info = rtti(obj);

        info.fields[0].get!string(obj).should == "quux";
        info.fields[1].get!string(obj).shouldThrowWithMessage("Cannot get private member");
        info.fields[2].toString(obj).should == "33.3";
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

    with(extendRTTI!Int) {
        const info = rtti!Int;
        info.toString(new Int(42)).should == "Int(42)";
        info.toString(new Int(88)).should == "Int(88)";

        enum testName = __traits(identifier, __traits(parent, {}));
        enum prefix = __MODULE__ ~ "." ~ testName ~ ".";
        info.toString(new Double(33.3)).shouldThrowWithMessage(
            "Cannot call toString on obj since not of type " ~ prefix ~ "Int");
    }
}
