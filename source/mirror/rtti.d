/**
   Runtime type information extraced from compile-tine.
 */
module mirror.rtti;


/**
   Initialise a `Types` variable (module-level, static struct
   variable, ...)  with runtime type information for the given types.
 */
mixin template typesVar(alias symbol, T...) {
    shared static this() nothrow {
        symbol = types!T;
    }
}

/**
   Extend runtime type information for the given types.
 */
Types types(T...)() {

    static RuntimeTypeInfo runtimeTypeInfo(T)() {

        import mirror.meta.traits: Fields;

        auto ret = new RuntimeTypeInfoImpl!T();

        ret.typeInfo = typeid(T);
        ret.name = ret.typeInfo.toString;

        static if(is(T == class)) {
            static foreach(field; Fields!T) {
                ret.fields ~= new FieldImpl!(T, field.Type, field.identifier)
                                            (typeid(field.Type), field.protection);
            }
        }

        return ret;
    }

    auto ret = Types();

    static foreach(Type; T) {
        ret._typeToInfo[typeid(Type)] = runtimeTypeInfo!Type;
    }

    return ret;
}


/**
   Maps types or instances of them to their runtime
   type information.
 */
struct Types {

    private RuntimeTypeInfo[TypeInfo] _typeToInfo;

    auto rtti(T)() inout {
        return rtti(typeid(T));
    }

    auto rtti(T)(auto ref T obj) inout {
        import std.traits: isPointer;

        static if(is(T == class)) {
            if(obj is null)
                throw new Exception("Cannot get RTTI from null object");
        }

        return rtti(typeid(obj));
    }

    auto rtti(scope TypeInfo typeInfo) @safe pure scope inout {
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
    Field[] fields;

    abstract string toString(in Object obj) @safe pure scope const;

    inout(Field) field(in string identifier) @safe pure scope inout {
        import std.array: empty, front;
        import std.algorithm.searching: find;

        auto ret = fields.find!(a => a.identifier == identifier);

        if(ret.empty)
            throw new Exception("No field named '" ~ identifier ~ "'");

        return ret.front;
    }
}


private class RuntimeTypeInfoImpl(T): RuntimeTypeInfo {

    override string toString(in Object obj) @safe pure scope const {
        import std.conv: text;
        import std.traits: fullyQualifiedName;

        static if(is(T == class)) {
            scope rightType = cast(const T) obj;
            if(rightType is null)
                throw new Exception("Cannot call toString on obj since not of type " ~ fullyQualifiedName!T);
            return text(cast(const T) obj);
        } else
            throw new Exception("Cannot cast non-class type " ~ fullyQualifiedName!T);
    }
}


/**
   Fields of a struct/class
 */
abstract class Field {

    import mirror.trait_enums: Protection;
    import std.variant: Variant;

    TypeInfo typeInfo;
    string type;
    string identifier;
    Protection protection;

    this(TypeInfo typeInfo, string type, string identifier, in Protection protection) @safe pure scope {
        this.typeInfo = typeInfo;
        this.type = type;
        this.identifier = identifier;
        this.protection = protection;
    }

    auto get(T, O)(O obj) const {
        import std.traits: CopyTypeQualifiers, fullyQualifiedName;

        auto variant = getImpl(obj);
        scope ptr = () @trusted { return variant.peek!T; }();

        if(ptr is null)
            throw new Exception("Cannot get!(" ~ fullyQualifiedName!T ~ ") because of actual type " ~ variant.type.toString);

        return cast(CopyTypeQualifiers!(O, T)) *ptr;
    }

    void set(T)(Object obj, T value) const {
        setImpl(obj, () @trusted { return Variant(value); }());
    }

    abstract inout(Variant) getImpl(inout Object obj) @safe const;
    abstract void setImpl(Object obj, in Variant value) @safe const;
    abstract string toString(in Object obj) @safe const;
}


private class FieldImpl(P, F, string member): Field {

    import std.variant: Variant;

    this(TypeInfo typeInfo, in Protection protection) {
        import std.traits: fullyQualifiedName;
        super(typeInfo, fullyQualifiedName!F, member, protection);
    }

    override inout(Variant) getImpl(inout Object obj) @safe const {
        import std.traits: Unqual;

        auto member = getMember(obj);
        auto ret = () @trusted {
            return Variant(cast(Unqual!(typeof(member))) member);
        }();

        return ret;
    }

    override void setImpl(Object obj, in Variant value) @safe const {
        import std.traits: fullyQualifiedName;

        auto ptr = () @trusted { return value.peek!F; }();
        if(ptr is null)
            throw new Exception("Cannot set value since not of type " ~ fullyQualifiedName!F);

        getMember(obj) = *ptr;
    }

    override string toString(in Object obj) @safe const {
        import std.conv: text;
        return get!F(obj).text;
    }

private:

    ref getMember(O)(O obj) const {

        import mirror.trait_enums: Protection;
        import std.traits: Unqual, fullyQualifiedName, CopyTypeQualifiers;
        import std.algorithm: among;

        if(!protection.among(Protection.export_, Protection.public_))
            throw new Exception("Cannot get private member");

        scope rightType = cast(CopyTypeQualifiers!(O, P)) obj;
        if(rightType is null)
            throw new Exception(
                "Cannot call get!" ~
                fullyQualifiedName!F ~ " since not of type " ~
                fullyQualifiedName!P);

        return __traits(getMember, rightType, member);
    }
}
