module mirror.rtti;


immutable(RuntimeTypeInfo) rtti(T)(auto ref T obj) {
    import std.string: split;

    auto ret = RuntimeTypeInfo();

    ret.type = Type(typeid(obj).toString);

    return ret;
}


struct RuntimeTypeInfo {
    Type type;
}

struct Type {

    string name;
    string fullyQualifiedName;

    this(string fullyQualifiedName) @safe pure nothrow scope {
        import std.string: split;

        this.fullyQualifiedName = fullyQualifiedName;
        this.name = fullyQualifiedName.split(".")[$-1];
    }
}
