module mirror.rtti;


RuntimeTypeInfo rtti(T)(auto ref T obj) {
    import std.string: split;

    auto ret = RuntimeTypeInfo();

    ret.typeInfo = typeid(obj);
    ret.type = Type(ret.typeInfo.toString);

    return ret;
}


struct RuntimeTypeInfo {
    TypeInfo typeInfo;
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
