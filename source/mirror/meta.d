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
    private alias overloads(alias member) = __traits(getOverloads, mod, member.identifier);
    private template isMemberSomeFunction(alias member) {
        import std.traits: isSomeFunction;
        enum isMemberSomeFunction = isSomeFunction!(member.symbol);
    }
    private alias functionSymbols = staticMap!(overloads, Filter!(isMemberSomeFunction, publicMembers));
    private enum toFunction(alias F) = Function!F();
    alias Functions = staticMap!(toFunction, functionSymbols);
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
struct Function(alias S) {
    alias symbol = S;
    string protection = __traits(getProtection, symbol);
    string linkage = __traits(getLinkage, symbol);

    string toString() @safe pure nothrow {
        import std.conv: text;
        import std.traits: fullyQualifiedName;
        return text(`Function(`, fullyQualifiedName!symbol, ", ", protection, ", ", linkage, ")");
    }
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
