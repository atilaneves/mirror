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
    private enum toFunction(alias member) = Function!(mod, member.symbol, member.identifier)();
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
struct Function(alias M, alias F, string I = __traits(identifier, F)) {

    alias module_ = M;
    alias symbol = F;
    enum identifier = I;
    alias overloads = __traits(getOverloads, module_, identifier);

    Protection protection = __traits(getProtection, symbol).toProtection;
    string linkage = __traits(getLinkage, symbol);

    string toString() @safe pure {
        import std.conv: text;
        import std.traits: fullyQualifiedName;
        return text(`Function(`, fullyQualifiedName!symbol, ", ", protection, ", ", linkage, ")");
    }
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
