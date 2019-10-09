/**
   This module provides the template metaprogramming variant of compile-time
   reflection, allowing client code to do type-level computations on the
   contents of a D module.
 */
module mirror.meta;


/**
   Compile-time information on a D module.
 */
template Module(string moduleName) {
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

    private template notPrivate(alias member) {
        // If a module contains an alias to a basic type, e.g. `alias L = long;`,
        // then __traits(getProtection, member) fails to compile
        static if(__traits(compiles, __traits(getProtection, member.symbol)))
            enum notPrivate = __traits(getProtection, member.symbol) != "private";
        else
            enum notPrivate = false;
    }

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
    private enum toVariable(alias member) = Variable!(typeof(member.symbol))(__traits(identifier, member.symbol));
    alias Variables = staticMap!(toVariable, Filter!(isVariable, publicMembers));


    // Function definitions
    private template isMemberSomeFunction(alias member) {
        import std.traits: isSomeFunction;
        enum isMemberSomeFunction = isSomeFunction!(member.symbol);
    }
    private alias functionMembers = Filter!(isMemberSomeFunction, publicMembers);
    private enum toFunction(alias member) = Function!(member.symbol, member.identifier, mod)();
    alias Functions = staticMap!(toFunction, functionMembers);
}


/**
   A global variable.
 */
struct Variable(T) {
    alias Type = T;
    string name;
}


/**
   A function.
 */
struct Function(alias F, string I = __traits(identifier, F), alias M = moduleOf!F) {

    alias symbol = F;
    enum identifier = I;
    alias module_ = M;
    alias overloads = __traits(getOverloads, module_, identifier);

    Protection protection = __traits(getProtection, symbol).toProtection;
    Linkage linkage = __traits(getLinkage, symbol).toLinkage;

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


private template moduleOf(alias T) {
    import std.traits: moduleName;
    mixin(`import `, moduleName!T, `;`);
    mixin(`alias moduleOf = `, moduleName!T, `;`);
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


/// Usable as a predicate to std.meta.Filter
enum isEnum(T) = is(T == enum);

/// Usable as a predicate to std.meta.Filter
enum isStruct(T) = is(T == struct);

/// Usable as a predicate to std.meta.Filter
enum isInterface(T) = is(T == interface);

/// Usable as a predicate to std.meta.Filter
enum isClass(T) = is(T == class);

/**
   If a type is a class or an interface.
   Usable as a predicate to std.meta.Filter
*/
enum isOOP(T) = is(T == class) || is(T == interface);
