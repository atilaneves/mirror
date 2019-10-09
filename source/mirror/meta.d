/**
   This module provides the template metaprogramming variant of compile-time
   reflection, allowing client code to do type-level computations on the
   contents of a D module.
 */
module mirror.meta;


import mirror.traits: moduleOf;


/**
   Compile-time information on a D module.
 */
template Module(string moduleName) {
    import mirror.traits: isPrivate;
    import std.meta: Filter, staticMap, Alias, AliasSeq;

    mixin(`import `, moduleName, `;`);
    private alias mod = Alias!(mixin(moduleName));

    private alias memberNames = __traits(allMembers, mod);

    private template member(string name) {
        import std.meta: Alias, AliasSeq;

        enum identifier = name;

        static if(__traits(compiles, Alias!(__traits(getMember, mod, name))))
            alias symbol = Alias!(__traits(getMember, mod, name));
        else
            alias symbol = AliasSeq!();
    }
    private alias members = staticMap!(member, memberNames);

    enum notPrivate(alias member) = !isPrivate!(member.symbol);
    private alias publicMembers = Filter!(notPrivate, members);

    // User-defined types
    private template isMemberType(alias member) {
        import std.traits: isType;
        enum isMemberType = isType!(member.symbol);
    }
    private alias symbolOf(alias member) = member.symbol;
    alias Aggregates = staticMap!(symbolOf, Filter!(isMemberType, publicMembers));


    // Global variables
    private enum isVariable(alias member) = is(typeof(member.symbol));
    private alias toVariable(alias member) = Variable!(typeof(member.symbol), __traits(identifier, member.symbol));
    alias Variables = staticMap!(toVariable, Filter!(isVariable, publicMembers));


    // Function definitions
    private template isMemberSomeFunction(alias member) {
        import std.traits: isSomeFunction;
        enum isMemberSomeFunction = isSomeFunction!(member.symbol);
    }
    private alias functionMembers = Filter!(isMemberSomeFunction, publicMembers);
    private alias toFunction(alias member) = Function!(
        member.symbol,
        __traits(getProtection, member.symbol).toProtection,
        __traits(getLinkage, member.symbol).toLinkage,
        member.identifier,
        mod,
    );
    alias Functions = staticMap!(toFunction, functionMembers);
}


/**
   A global variable.
 */
template Variable(T, string N) {
    alias Type = T;
    enum name = N;
}


/**
   A function.
 */
template Function(
    alias F,
    Protection P = __traits(getProtection, F).toProtection,
    Linkage L = __traits(getLinkage, F).toLinkage,
    string I = __traits(identifier, F),
    alias M = moduleOf!F
)
{
    import std.traits: RT = ReturnType;

    alias symbol = F;
    alias protection = P;
    alias linkage = L;
    enum identifier = I;
    alias module_ = M;

    alias overloads = __traits(getOverloads, module_, identifier);
    alias ReturnType = RT!symbol;

    template parametersImpl() {
        import std.traits: Parameters, ParameterIdentifierTuple, ParameterDefaults;
        import std.meta: staticMap, aliasSeqOf;
        import std.range: iota;

        alias parameter(size_t i) =
            Parameter!(Parameters!symbol[i], ParameterDefaults!symbol[i], ParameterIdentifierTuple!symbol[i]);
        alias parametersImpl = staticMap!(parameter, aliasSeqOf!(Parameters!F.length.iota));
    }

    alias parameters = parametersImpl!();

    string toString() @safe pure {
        import std.conv: text;
        import std.traits: fullyQualifiedName;
        return text(`Function(`, fullyQualifiedName!symbol, ", ", protection, ", ", linkage, ")");
    }
}


template Parameter(T, alias D, string I) {
    alias Type = T;
    alias Default = D;
    enum identifier = I;
}


/// Visibilty/protection
enum Protection {
    private_,
    protected_,
    public_,
    export_,
    package_,
}


Protection toProtection(in string str) @safe pure {
    import std.conv: to;
    return (str ~ "_").to!Protection;
}


///
enum Linkage {
    D,
    C,
    Cpp,
    Windows,
    ObjectiveC,
    System,
}


Linkage toLinkage(in string str) @safe pure {
    import std.conv: to;
    if(str == "C++") return Linkage.Cpp;
    return str.to!Linkage;
}
