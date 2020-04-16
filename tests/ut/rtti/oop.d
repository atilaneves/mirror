module ut.rtti.oop;


import ut;
import mirror.rtti;



@("type.class.abstract")
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

    foo.rtti.type.name.should == "Foo";
    bar.rtti.type.name.should == "Bar";

    enum testId = __traits(identifier, __traits(parent, {}));
    foo.rtti.type.fullyQualifiedName.should == __MODULE__ ~ "." ~ testId ~ ".Foo";
    bar.rtti.type.fullyQualifiedName.should == __MODULE__ ~ "." ~ testId ~ ".Bar";
}
