module modules.types;


struct String {
    string value;
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
