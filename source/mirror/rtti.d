module mirror.rtti;


/**
   Extend runtime type information for the given types.
 */
ExtendedRTTI extendRTTI(Types...)() {
    auto ret = ExtendedRTTI();

    static RuntimeTypeInfo runtimeTypeInfo(T)() {

        import mirror.traits: Fields;

        auto ret = RuntimeTypeInfo();

        ret.typeInfo = typeid(T);
        ret.type = Type(ret.typeInfo.toString);
        ret.type.fields.length = Fields!T.length;

        return ret;
    }

    static foreach(Type; Types) {
        ret._typeToInfo[typeid(Type)] = runtimeTypeInfo!Type;
    }

    return ret;
}


struct ExtendedRTTI {

    private RuntimeTypeInfo[TypeInfo] _typeToInfo;

    RuntimeTypeInfo rtti(T)(auto ref T obj) {

        scope typeInfo = typeid(obj);
        scope ptr = typeInfo in _typeToInfo;

        if(ptr is null) {
            // TypeInfo.toString isn't scope, so @trusted
            scope infoString = () @trusted { return typeInfo.toString; }();
            throw new Exception("Cannot get RTTI for unregistered type " ~ infoString);
        }

        return *ptr;
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
