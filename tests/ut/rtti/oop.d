module ut.rtti.oop;


import ut;
import mirror.rtti;


@("type.name")
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

        fooInfo.type.name.should == "Foo";
        barInfo.type.name.should == "Bar";

        enum testId = __traits(identifier, __traits(parent, {}));
        fooInfo.type.fullyQualifiedName.should == __MODULE__ ~ "." ~ testId ~ ".Foo";
        barInfo.type.fullyQualifiedName.should == __MODULE__ ~ "." ~ testId ~ ".Bar";
    }
}


@("type.typeInfo")
// The test is neither @safe nor pure because Object.opEquals isn't
unittest {

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


@("type.fields.0")
@safe pure unittest {

    static abstract class Abstract {}
    static class Class: Abstract {
        int i;
        string s;
    }
    const Abstract obj = new Class();

    with(extendRTTI!Class) {
        const info = rtti(obj);
        info.type.fields.should == [
            Field("int", "i"),
            Field("string", "s"),
        ];
    }
}


@("type.fields.1")
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
        info.type.fields.should == [
            Field("string", "s0"),
            Field("string", "s1"),
            Field("double", "d"),
            Field("string", "s2"),
        ];
    }
}
