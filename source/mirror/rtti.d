module mirror.rtti;


/**
   Extend runtime type information for the given types.
 */
ExtendedRTTI extendRTTI(Types...)() {

    static RuntimeTypeInfo runtimeTypeInfo(T)() {

        import mirror.traits: Fields;
        import std.string: split;

        auto ret = new RuntimeTypeInfoImpl!T();

        ret.typeInfo = typeid(T);
        ret.fullyQualifiedName = ret.typeInfo.toString;
        ret.name = ret.fullyQualifiedName.split(".")[$-1];

        static foreach(field; Fields!T) {
            ret.fields ~= Field(field.Type.stringof, field.identifier);
        }

        return ret;
    }

    auto ret = ExtendedRTTI();

    static foreach(Type; Types) {
        ret._typeToInfo[typeid(Type)] = runtimeTypeInfo!Type;
    }

    return ret;
}


struct ExtendedRTTI {

    private RuntimeTypeInfo[TypeInfo] _typeToInfo;

    RuntimeTypeInfo rtti(T)() {
        return rtti(typeid(T));
    }

    RuntimeTypeInfo rtti(T)(auto ref T obj) {
        if(obj is null)
            throw new Exception("Cannot get RTTI from null object");
        return rtti(typeid(obj));
    }

    RuntimeTypeInfo rtti(scope TypeInfo typeInfo) @safe pure scope {
        scope ptr = typeInfo in _typeToInfo;

        if(ptr is null) {
            // TypeInfo.toString isn't scope, so @trusted
            scope infoString = () @trusted { return typeInfo.toString; }();
            throw new Exception("Cannot get RTTI for unregistered type " ~ infoString);
        }

        return *ptr;
    }
}


abstract class RuntimeTypeInfo {
    TypeInfo typeInfo;
    string name;
    string fullyQualifiedName;
    Field[] fields;

    abstract string toString(in Object obj) @safe pure scope const;
}


class RuntimeTypeInfoImpl(T): RuntimeTypeInfo {
    override string toString(in Object obj) @safe pure scope const {
        import std.conv: text;
        import std.traits: fullyQualifiedName;

        scope rightType = cast(const T) obj;
        if(rightType is null)
            throw new Exception("Cannot call toString on obj since not of type " ~ fullyQualifiedName!T);
        return text(cast(const T) obj);
    }
}


struct Field {
    string type;
    string identifier;
}
