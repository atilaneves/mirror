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
alias RecursiveFieldTypes(T) = RecursiveFieldTypesImpl!T;


private template RecursiveFieldTypesImpl(T, alreadySeen...) {

    import mirror.traits: isStruct, isClass;
    import std.meta: staticMap, AliasSeq, NoDuplicates, Filter,
        templateNot, staticIndexOf;

    enum isStructOrClass(U) = isStruct!(FundamentalType!U) || isClass!(FundamentalType!U);

    static if(isStructOrClass!T) {

        private alias fields = AliasSeq!(T.tupleof);
        private alias publicFields = Filter!(templateNot!isPrivate, fields);
        private alias type(alias symbol) = typeof(symbol);
        private alias types = staticMap!(type, fields);

        private template recurse(U) {

            static if(isStructOrClass!U) {

                // only recurse if the type hasn't been seen yet to
                // prevent infinite recursion
                enum shouldRecurse = staticIndexOf!(U, alreadySeen) == -1;

                static if(shouldRecurse)
                    alias recurse = AliasSeq!(U, RecursiveFieldTypesImpl!(FundamentalType!U, NoDuplicates!(T, types, alreadySeen)));
                else
                    alias recurse = AliasSeq!();
            } else
                alias recurse = U;
        }

        alias RecursiveFieldTypesImpl = NoDuplicates!(staticMap!(recurse, types));
    } else
        alias RecursiveFieldTypesImpl = T;
}


/**
   An std.meta.AliasSeq of `T` and all its recursive
   subtypes.
 */
template RecursiveTypeTree(T...) {
    import std.meta: staticMap, NoDuplicates;
    alias RecursiveTypeTree = NoDuplicates!(T, staticMap!(RecursiveFieldTypes, T));
}


/**
   Whether or not `F` is a property function
 */
template isProperty(alias F) {
    import std.traits: functionAttributes, FunctionAttribute;
    enum isProperty = functionAttributes!F & FunctionAttribute.property;
}


/**
   All member function symbols in T with overloads represented
   separately.
 */
template MemberFunctions(T) if(isStruct!T || isClass!T || isInterface!T)
{
    import mirror.meta: functionsByOverload, Protection;
    import std.meta: Filter, staticMap;

    private enum isPublic(alias F) = F.protection != Protection.private_;
    private alias symbolOf(alias S) = S.symbol;

    alias MemberFunctions = Filter!(isMemberFunction,
                                    staticMap!(symbolOf,
                                               Filter!(isPublic,
                                                       functionsByOverload!(T, PublicMembers!T))));
}


// must be a global template
private template isMemberFunction(alias F) {
    import std.algorithm: startsWith;

    static if(__traits(compiles, __traits(identifier, F))) {
        enum name = __traits(identifier, F);
        alias parent = __traits(parent, F);

        static if(isOOP!parent) {
            private static bool isWantedFunction(string name) {
                import std.algorithm: among;
                return
                    !name.among("toString", "toHash", "opCmp", "opEquals", "factory")
                    && !name.startsWith("__")
                    ;
            }
        } else {
            bool isWantedFunction(string name) { return true; }
        }
        private bool isOperator(string name) {
            return name.startsWith("op") && name.length > 2 && name[2] >= 'A';
        }

        enum isOp = isOperator(name);
        enum isMemberFunction = isWantedFunction(name) && !isOperator(name);

    } else
        enum isMemberFunction = false;
}


template PublicMembers(alias A) {
    import mirror.traits: isPrivate;
    import std.meta: Filter, staticMap, Alias, AliasSeq;

    package template member(string name) {

        enum identifier = name;

        static if(__traits(compiles, Alias!(__traits(getMember, A, name)))) {

            alias symbol = Alias!(__traits(getMember, A, name));

            static if(is(symbol))
                alias Type = symbol;
            else static if(is(typeof(symbol)))
                alias Type = typeof(symbol);
            else
                alias Type = void;

        } else
            alias symbol = void;
    }

    private alias members = staticMap!(member, __traits(allMembers, A));

    // In the `member` template above, if it's not possible to get a member from `A`,
    // then the symbol is an empty AliasSeq. An example of such a situation can be
    // found in `modules.problems` from the tests directory, where this causes things
    // to not compile: `version = OopsVersion;`.
    // So we filter out such members.
    private enum hasSymbol(alias member) = !is(member == void);
    private alias goodMembers = Filter!(hasSymbol, members);

    private enum notPrivate(alias member) = !isPrivate!(member.symbol);

    alias PublicMembers = Filter!(notPrivate, goodMembers);
}


package template memberIsSomeFunction(alias member) {
    import std.traits: isSomeFunction;
    enum memberIsSomeFunction = isSomeFunction!(member.symbol);
}


package template memberIsRegularFunction(alias member) {
    static if(memberIsSomeFunction!member) {
        import std.algorithm: startsWith;
        enum memberIsRegularFunction =
            !member.identifier.startsWith("_sharedStaticCtor")
            && !member.identifier.startsWith("_staticCtor")
            ;
    } else
        enum memberIsRegularFunction = false;
}


/**
   If a function is static member function
 */
template isStaticMemberFunction(alias F) {
    import std.traits: hasStaticMember;

    static if(__traits(compiles, hasStaticMember!(__traits(parent, F), __traits(identifier, F))))
        enum isStaticMemberFunction = hasStaticMember!(__traits(parent, F), __traits(identifier, F));
    else
        enum isStaticMemberFunction = false;
}
