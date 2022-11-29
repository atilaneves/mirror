module modules.types;


struct String {
    string value;

    string withPrefix() @safe pure nothrow const {
        return "pre_" ~ value;
    }

    string withPrefix(in string prefix) @safe pure nothrow const {
        return prefix ~ value;
    }

}


enum Enum {
    foo,
    bar,
    baz,
}

class Class {
    int i;
    this(int i) { this.i = i; }
}


interface Interface {
    int foo(double d, string s);
}

class AbstractClass {
    abstract double bar(int i);
}

class MiddleClass: AbstractClass {
    string baz(string s);
}

class LeafClass: MiddleClass, Interface {
    override int foo(double d, string s) {
        return 42;
    }

    override double bar(int i) {
        return i * 2;
    }

    override string baz(string s) {
        return s ~ "_baz";
    }
}


// just to test this gets ignored
int func(string s, double d) {
    return 42;
}


struct Point {
    double x, y;
}


struct Inner1 {
    Point point;
    double value;
}


struct EvenInner {
    double value;
}


struct Inner2 {
    EvenInner evenInner;
}


struct Outer {
    Inner1[] inner1s;
    Inner2 inner2;
}


enum Char: char {
    a = 'a',
    b = 'b',
}

union Union {

}
