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


@("fields.0")
@safe pure unittest {

    static abstract class Abstract {}
    static class Class: Abstract {
        int i;
        string s;
    }
    const Abstract obj = new Class();

    with(extendRTTI!Class) {
        const info = rtti(obj);
        info.fields.should == [
            Field("int", "i"),
            Field("string", "s"),
        ];
    }
}


@("fields.1")
@safe pure unittest {

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
        info.fields.should == [
            Field("string", "s0"),
            Field("string", "s1"),
            Field("double", "d"),
            Field("string", "s2"),
        ];
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
