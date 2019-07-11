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
    import std.traits: isSomeFunction, isType;

    mixin(`import `, moduleName, `;`);
    private alias mod = Alias!(mixin(moduleName));

    private alias memberNames = __traits(allMembers, mod);

    private template member(string name) {
        import std.meta: Alias, AliasSeq;
        static if(__traits(compiles, Alias!(__traits(getMember, mod, name))))
            alias member = Alias!(__traits(getMember, mod, name));
        else
            alias member = AliasSeq!();
    }
    private alias members = staticMap!(member, memberNames);
    private enum notPrivate(alias T) = __traits(getProtection, T) != "private";
    private alias publicMembers = Filter!(notPrivate, members);

    // User-defined types
    alias Aggregates = Filter!(isType, publicMembers);

    // Global variables
    private enum isVariable(alias member) = is(typeof(member));
    private enum toVariable(alias member) = Variable!(typeof(member))(__traits(identifier, member));
    alias Variables = staticMap!(toVariable, Filter!(isVariable, publicMembers));

    // Function definitions
    private alias overloads(alias F) = __traits(getOverloads, mod, __traits(identifier, F));
    alias Functions = staticMap!(overloads, Filter!(isSomeFunction, publicMembers));
}


/**
   A global variable.
 */
struct Variable(T) {
    alias Type = T;
    string name;
}


/// Usable as a predicate to std.meta.Filter
enum isEnum(T) = is(T == enum);

/// Usable as a predicate to std.meta.Filter
enum isStruct(T) = is(T == struct);

/// Usable as a predicate to std.meta.Filter
enum isInterface(T) = is(T == interface);

/// Usable as a predicate to std.meta.Filter
enum isClass(T) = is(T == class);
