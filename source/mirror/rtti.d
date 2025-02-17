/**
   Runtime type information extraced from compile-tine.
 */
module mirror.rtti;


/**
   Initialise a `Types` variable (module-level, static struct
   variable, ...) with runtime type information for the given types.
 */
mixin template typesVar(alias symbol, T...) {
    shared static this() nothrow {
        symbol = cast(typeof(symbol)) types!T;
    }
}

/**
   Extend runtime type information for the given types.
 */
Types types(T...)() {

    auto ret = Types();

    static foreach(Type; T) {
        ret._typeToInfo[typeid(Type)] = runtimeTypeInfo!Type;
    }

    return ret;
}


RuntimeTypeInfo runtimeTypeInfo(T)() {

    import mirror.meta.traits: Fields, MemberFunctionsByOverload;

    auto ret = new RuntimeTypeInfoImpl!T();

    ret.typeInfo = typeid(T);
    ret.name = ret.typeInfo.toString;

    static if(is(T == class)) {

        static foreach(field; Fields!T) {
            ret.fields ~= new FieldImpl!(T, field.Type, field.identifier)
                (typeid(field.Type), field.protection);
        }

        static foreach(memberFunction; MemberFunctionsByOverload!T) {
            ret.methods ~= new MethodImpl!memberFunction();
        }
    }

    return ret;
}


/**
   Maps types or instances of them to their runtime
   type information.
 */
struct Types {

    private RuntimeTypeInfo[TypeInfo] _typeToInfo;

    inout(RuntimeTypeInfo) rtti(T)() inout {
        return rtti(typeid(T));
    }

    inout(RuntimeTypeInfo) rtti(T)(auto ref T obj) inout {
        import std.traits: isPointer;

        static if(is(T == super)) {
            if(obj is null)
                throw new Exception("Cannot get RTTI from null object");
        }

        return rtti(typeid(obj));
    }

    inout(RuntimeTypeInfo) rtti(scope TypeInfo typeInfo) @safe scope inout {
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
    Method[] methods;

    abstract string toString(in Object obj) @safe pure scope const;

    final inout(Field) field(in string identifier) @safe pure scope inout {
        return findInArray(identifier, "field", fields);
    }

    final inout(Method) method(in string identifier) @safe pure scope inout {
        return findInArray(identifier, "method", methods);
    }

    private static findInArray(T)(in string identifier, in string kind, T arr) {
        import std.array: empty, front;
        import std.algorithm.searching: find;

        auto ret = arr.find!(a => a.identifier == identifier);

        if(ret.empty)
            throw new Exception("No " ~ kind ~ " named '" ~ identifier ~ "'");

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

    const RuntimeTypeInfo type;
    immutable string identifier;
    immutable Protection protection;

    this(const RuntimeTypeInfo type, string identifier, in Protection protection) @safe pure scope {
        this.type = type;
        this.identifier = identifier;
        this.protection = protection;
    }

    final get(T, O)(O obj) const {
        import std.traits: CopyTypeQualifiers, fullyQualifiedName;

        auto variant = getImpl(obj);
        scope ptr = () @trusted { return variant.peek!T; }();

        if(ptr is null)
            throw new Exception("Cannot get!(" ~ fullyQualifiedName!T ~ ") because of actual type " ~ variant.type.toString);

        return cast(CopyTypeQualifiers!(O, T)) *ptr;
    }

    final void set(T)(Object obj, T value) const {
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
        super(runtimeTypeInfo!F, member, protection);
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

        static if(is(F == immutable))
            throw new Exception("Cannot set immutable member '" ~ identifier ~ "'");
        else static if(is(F == const))
            throw new Exception("Cannot set const member '" ~ identifier ~ "'");
        else {

            auto ptr = () @trusted { return value.peek!F; }();
            if(ptr is null)
                throw new Exception("Cannot set value since not of type " ~ fullyQualifiedName!F);

            getMember(obj) = *ptr;
        }
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

        auto rightType = cast(CopyTypeQualifiers!(O, P)) obj;
        if(rightType is null)
            throw new Exception(
                "Cannot call get!" ~
                fullyQualifiedName!F ~ " since not of type " ~
                fullyQualifiedName!P);

        return __traits(getMember, rightType, member);
    }
}

abstract class Method {

    import std.variant: Variant;

    enum TypeQualifier {
        mutable,
        const_,
        immutable_,
    }

    immutable string identifier;
    const RuntimeTypeInfo type;

    this(string identifier, const RuntimeTypeInfo type) @safe @nogc pure scope const {
        this.identifier = identifier;
        this.type = type;
    }

    final override string toString() @safe pure scope const {
        return reprImpl();
    }

    final R call(R = void, O, A...)(O obj, A args) const {
        Variant[A.length] variants;
        static foreach(i; 0 .. A.length) variants[i] = args[i];

        static if(is(O == immutable))
            const qualifier = TypeQualifier.immutable_;
        else static if(is(O == const))
            const qualifier = TypeQualifier.const_;
        else
            const qualifier = TypeQualifier.mutable;

        auto impl() {
            return callImpl(qualifier, obj, variants[]);
        }

        static if(is(R == void))
            impl;
        else
            return impl.get!R;
    }

    final bool isVirtual() @safe @nogc pure scope const {
        return !isFinal && !isStatic;
    }

    abstract size_t arity() @safe @nogc pure scope const;
    abstract bool isFinal() @safe @nogc pure scope const;
    abstract bool isOverride() @safe @nogc pure scope const;
    abstract bool isStatic() @safe @nogc pure scope const;
    abstract bool isSafe() @safe @nogc pure scope const;
    abstract RuntimeTypeInfo returnType() @safe scope const;
    abstract RuntimeTypeInfo[] parameters() @safe scope const;
    abstract string reprImpl() @safe pure scope const;
    abstract Variant callImpl(TypeQualifier objQualifier, inout Object obj, Variant[] args) const;
}


class MethodImpl(alias F): Method {

    this() const {
        super(__traits(identifier, F), runtimeTypeInfo!(typeof(F)));
    }

    override string reprImpl() @safe pure scope const {
        import std.traits: ReturnType, Parameters;
        import std.conv: text;
        return text(ReturnType!F.stringof, " ", __traits(identifier, F), Parameters!F.stringof);
    }

    override Variant callImpl(TypeQualifier objQualifier, inout Object obj, Variant[] variantArgs) const {
        import std.typecons: Tuple;
        import std.traits: Parameters, ReturnType, FA = FunctionAttribute, hasFunctionAttributes;
        import std.conv: text;

        if(variantArgs.length != Parameters!F.length)
            throw new Exception(text("'", identifier, "'", " takes ",
                                     Parameters!F.length, " parameter(s), not ", variantArgs.length));

        Tuple!(Parameters!F) args;

        alias RightType = __traits(parent, F);
        auto rightType = cast(RightType) obj;

        if(rightType is null)
            throw new Exception("Cannot call '" ~ identifier ~ "' on object not of type " ~ RightType.stringof);

        const isObjConstant = objQualifier == TypeQualifier.const_ || objQualifier == TypeQualifier.immutable_;
        if(isObjConstant && !hasFunctionAttributes!(F, "const"))
           throw new Exception("Cannot call non-const method '" ~ identifier ~ "' on const obj");

        enum mixinStr = `rightType.` ~ __traits(identifier, F) ~ `(args.expand)`;

        static if(__traits(compiles, mixin(mixinStr))) {

            static foreach(i; 0 .. args.length) {
                args[i] = variantArgs[i].get!(typeof(args[i]));
            }

            static if(is(ReturnType!F == void)) {
                mixin(mixinStr, `;`);
                return Variant.init;
            } else {
                auto ret = mixin(mixinStr);
                return Variant(ret);
            }
        } else
            throw new Exception("Cannot call " ~ identifier ~ " on object");
    }

    override bool isFinal() @safe @nogc pure scope const {
        import std.traits: isFinalFunction;
        return isFinalFunction!F;
    }

    override bool isOverride() @safe @nogc pure scope const {
        return __traits(isOverrideFunction, F);
    }

    override bool isStatic() @safe @nogc pure scope const {
        return __traits(isStaticFunction, F);
    }

    override bool isSafe() @safe @nogc pure scope const {
        import std.traits: isSafe;
        return isSafe!F;
    }

    override size_t arity() @safe @nogc pure scope const {
        import std.traits: arity;
        return arity!F;
    }

    override RuntimeTypeInfo returnType() @safe scope const {
        import std.traits: ReturnType;
        return runtimeTypeInfo!(ReturnType!F);
    }

    override RuntimeTypeInfo[] parameters() @safe scope const {
        import std.traits: Parameters;

        RuntimeTypeInfo[] ret;

        static foreach(parameter; Parameters!F) {
            ret ~= runtimeTypeInfo!parameter;
        }

        return ret;
    }
}
