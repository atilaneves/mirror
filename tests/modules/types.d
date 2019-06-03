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
