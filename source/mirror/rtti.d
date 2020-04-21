module mirror.rtti;


/**
   Extend runtime type information for the given types.
 */
ExtendedRTTI extendRTTI(T...)() {
    return ExtendedRTTI();
}


struct ExtendedRTTI {

    RuntimeTypeInfo rtti(T)(auto ref T obj) {
        import mirror.traits: Fields;
        import std.string: split;
        import std.algorithm: map;
        import std.array: array;

        auto ret = RuntimeTypeInfo();

        ret.typeInfo = typeid(obj);
        ret.type = Type(ret.typeInfo.toString);

        return ret;
    }
}


struct RuntimeTypeInfo {
    TypeInfo typeInfo;
    Type type;
}


struct Type {

    string name;
    string fullyQualifiedName;
    Field[] fields;

    this(string fullyQualifiedName) @safe pure nothrow scope {
        import std.string: split;

        this.fullyQualifiedName = fullyQualifiedName;
        this.name = fullyQualifiedName.split(".")[$-1];
    }
}


struct Field {

}
