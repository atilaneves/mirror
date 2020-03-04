/**
   A fictional language implemented in D
 */
module blub;


import std.traits: Unqual;


struct Blub {
    enum Kind {
        integer,
        string,
    }

    Kind kind;
    // normally we'd use a union but meh about storage here
    private int _integer;
    private string _string;

    @disable this();

    this(int i) @safe @nogc pure nothrow {
        kind = Kind.integer;
        _integer = i;
    }

    this(string s) @safe @nogc pure nothrow {
        kind = Kind.string;
        _string = s;
    }

    int asInteger() @safe @nogc pure const {
        if(kind != Kind.integer) throw new Exception("not an int");
        return _integer;
    }

    string asString() @safe @nogc pure const {
        if(kind != Kind.string) throw new Exception("not a string");
        return _string;
    }
}


Blub toBlub(int i) {
    return Blub(i);
}

Blub toBlub(string s) {
    return Blub(s);
}

T to(T)(Blub blub) if(is(Unqual!T == int)) {
    return blub.asInteger;
}

T to(T)(Blub blub) if(is(Unqual!T == string)) {
    return blub.asString;
}
