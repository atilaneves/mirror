module mirror.rtti;


/**
   Extend runtime type information for the given types.
 */
ExtendedRTTI extendRTTI(Types...)() {
    auto ret = ExtendedRTTI();

    static RuntimeTypeInfo runtimeTypeInfo(T)() {

        import mirror.traits: Fields;
        import std.string: split;

        auto ret = RuntimeTypeInfo();

        ret.typeInfo = typeid(T);
        ret.fullyQualifiedName = ret.typeInfo.toString;
        ret.name = ret.fullyQualifiedName.split(".")[$-1];

        static foreach(field; Fields!T) {
            ret.fields ~= Field(field.Type.stringof, field.identifier);
        }

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
    string name;
    string fullyQualifiedName;
    Field[] fields;
}


struct Field {
    string type;
    string identifier;
}
