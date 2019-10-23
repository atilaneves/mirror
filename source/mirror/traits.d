/**
   Information about types and symbols at compile-time,
   similar to std.traits.
 */
module mirror.traits;


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


template moduleOf(alias T) {
    import std.traits: moduleName;
    mixin(`import `, moduleName!T, `;`);
    mixin(`alias moduleOf = `, moduleName!T, `;`);
}


template isPrivate(alias symbol) {
    // If a module contains an alias to a basic type, e.g. `alias L = long;`,
    // then __traits(getProtection, member) fails to compile
    static if(__traits(compiles, __traits(getProtection, symbol)))
        enum isPrivate = __traits(getProtection, symbol) == "private";
    else
        enum isPrivate = true;  // if it doesn't compile, treat it as private
}


/**
   Retrieves the "fundamental type" of a type T.  For most types, this
   will be exactly the same as T itself.  For arrays or pointers, it
   removes as many "layers" of array or pointer indirections to get to
   the most basic atomic type possible.  Examples of inputs and
   outputs:

   * T -> T
   * T[] -> T
   * T[][] -> T
   * T* -> T

 */
template FundamentalType(T) {

    import std.traits: isArray, isPointer, PointerTarget;
    import std.range: ElementEncodingType;

    static if(isArray!T)
        alias removeOneIndirection = ElementEncodingType!T;
    else static if(isPointer!T)
        alias removeOneIndirection = PointerTarget!T;

    private enum isArrayOrPointer(U) = isArray!U || isPointer!U;

    static if(isArrayOrPointer!T) {
        static if(isArrayOrPointer!removeOneIndirection)
            alias FundamentalType = FundamentalType!removeOneIndirection;
        else
            alias FundamentalType = removeOneIndirection;
    } else
        alias FundamentalType = T;
}


/**
   Returns an AliasSeq of all field types of `T`, depth-first
   recursively.
 */
template RecursiveFieldTypes(T, alreadySeen...) {

    import mirror.meta: PublicMembers;
    import mirror.traits: isStruct, isClass;
    import std.meta: staticMap, AliasSeq, NoDuplicates, Filter,
        templateNot, staticIndexOf;

    enum isStructOrClass(U) = isStruct!U || isClass!U;

    static if(isStructOrClass!T) {

        private alias fields = AliasSeq!(T.tupleof);
        private alias publicFields = Filter!(templateNot!isPrivate, fields);
        private alias type(alias symbol) = typeof(symbol);
        private alias types = staticMap!(type, fields);

        private template recurse(U) {

            static if(isStructOrClass!U && !is(T == U)) {

                // only recurse if the type hasn't been seen yet to
                // prevent infinite recursion
                enum shouldRecurse = staticIndexOf!(U, alreadySeen) == -1;

                static if(shouldRecurse)
                    alias recurse = AliasSeq!(U, RecursiveFieldTypes!(U, NoDuplicates!(T, types, alreadySeen)));
                else
                    alias recurse = AliasSeq!();
            } else
                alias recurse = U;
        }

        alias RecursiveFieldTypes = NoDuplicates!(staticMap!(recurse, types));
    } else
        alias RecursiveFieldTypes = T;
}
