/**
   This module provides the template metaprogramming variant of compile-time
   reflection, allowing client code to do type-level computations on the
   contents of a D module.
 */
module mirror.meta.reflection;


import mirror.trait_enums: Protection, toProtection, Linkage, toLinkage;
import std.meta: Alias;

/**
   Compile-time information on a D module.
 */
template Module(string moduleName) {

    import mirror.meta.traits: RecursiveTypeTree, RecursiveFieldTypes, FundamentalType, PublicMembers,
        MemberFunctionsByOverload;
    import std.meta: Alias, NoDuplicates, Filter, staticMap, templateNot;

    mixin(`import `, moduleName, `;`);
    private alias mod = Alias!(mixin(moduleName));

    private alias publicMembers = PublicMembers!mod;

    /// User-defined structs/classes
    alias Aggregates = aggregates!publicMembers;
    private enum isEnum(T) = is(T == enum);
    private alias memberFunctions =
        staticMap!(MemberFunctionsByOverload,
                   Filter!(templateNot!isEnum, Aggregates));

    private template isAggregate(T) {
        alias U = FundamentalType!T;
        enum isAggregate = is(U == enum) || is(U == struct) || is(U == class) || is(U == interface) || is(U == union);
    }

    /// User-defined structs/classes and all types contained in them
    alias AggregatesTree = Filter!(isAggregate, RecursiveTypeTree!Aggregates);

    /// Global variables/enums
    alias Variables = variables!publicMembers;

    /// List of functions by symbol - contains overloads for each entry
    alias FunctionsBySymbol = functionsBySymbol!(mod, publicMembers);

    /// List of functions by overload - each overload is a separate entry
    alias FunctionsByOverload = functionsByOverload!(mod, publicMembers);

    alias AllFunctionReturnTypes = NoDuplicates!(returnTypes!FunctionsByOverload, returnTypes!memberFunctions);
    alias AllFunctionReturnTypesTree = RecursiveTypeTree!AllFunctionReturnTypes;

    alias AllFunctionParameterTypes = NoDuplicates!(parameterTypes!FunctionsByOverload, parameterTypes!memberFunctions);
    alias AllFunctionParameterTypesTree = RecursiveTypeTree!AllFunctionParameterTypes;

    /**
       All aggregates, including explicitly defined and appearing in
       function signatures
    */
    alias AllAggregates =
        NoDuplicates!(
            staticMap!(FundamentalType,
                       Filter!(isAggregate,
                               AggregatesTree, AllFunctionReturnTypesTree, AllFunctionParameterTypesTree)
        )
    );
}


private template returnTypes(functions...) {

    import mirror.meta.traits: FundamentalType;
    import std.traits: ReturnType;
    import std.meta: staticMap, NoDuplicates;

    private template symbol(alias F) {
        import std.traits: isSomeFunction;
        static if(isSomeFunction!F)
            alias symbol = F;
        else
            alias symbol = F.symbol;
    }

    alias returnTypes =
        NoDuplicates!(staticMap!(FundamentalType,
                                 staticMap!(ReturnType,
                                            staticMap!(symbol, functions))));
}

private template parameterTypes(functions...) {

    import mirror.meta.traits: FundamentalType;
    import std.traits: Parameters;
    import std.meta: staticMap, NoDuplicates;

    private template symbol(alias F) {
        import std.traits: isSomeFunction;
        static if(isSomeFunction!F)
            alias symbol = F;
        else
            alias symbol = F.symbol;
    }

    alias parameterTypes =
        NoDuplicates!(staticMap!(FundamentalType,
                                 staticMap!(Parameters,
                                            staticMap!(symbol, functions))));
}


// User-defined types
package template aggregates(publicMembers...) {
    import std.meta: staticMap, Filter;

    private template memberIsType(alias member) {
        import std.traits: isType;
        enum memberIsType = isType!(member.symbol);
    }

    private alias symbolOf(alias member) = member.symbol;

    alias aggregates = staticMap!(symbolOf, Filter!(memberIsType, publicMembers));
}


// Global variables
private template variables(publicMembers...) {
    import mirror.meta.traits: isMutableSymbol, isVariable;
    import std.meta: staticMap, Filter;

    private template toVariable(alias member) {
        alias T = member.Type;
        enum id = member.identifier;

        static if(__traits(compiles, Variable!(T, id, member.symbol, !isMutableSymbol!(member.symbol))))
            alias toVariable = Variable!(T, id, member.symbol, !isMutableSymbol!(member.symbol));
        else
            alias toVariable = Variable!(T, id, T.init, !isMutableSymbol!(member.symbol));
    }

    alias variables = staticMap!(toVariable, Filter!(isVariable, publicMembers));
}

/**
   A global variable.
 */
template Variable(T, string N, alias V, bool C) {
    alias Type = T;
    enum identifier = N;
    enum value = V;
    enum isConstant = C;
}

template FunctionsBySymbol(alias parent) {
    import mirror.meta.traits : PublicMembers;
    alias FunctionsBySymbol = functionsBySymbol!(parent, PublicMembers!parent);
}

private template functionsBySymbol(alias parent, publicMembers...) {

    import mirror.meta.traits: memberIsRegularFunction;
    import std.meta: Filter, staticMap;

    private alias functionMembers = Filter!(memberIsRegularFunction, publicMembers);

    private alias toFunction(alias member) = FunctionSymbol!(
        member.symbol,
        __traits(getProtection, member.symbol).toProtection,
        __traits(getLinkage, member.symbol).toLinkage,
        member.identifier,
        parent,
        );

    alias functionsBySymbol = staticMap!(toFunction, functionMembers);
}


/**
   A function symbol with nested overloads.
 */
template FunctionSymbol(
    alias F,
    Protection P = __traits(getProtection, F).toProtection,
    Linkage L = __traits(getLinkage, F).toLinkage,
    string I = __traits(identifier, F),
    alias Parent = Alias!(__traits(parent, F)),
)
{
    import std.meta: staticMap;

    alias symbol = F;
    enum identifier = I;
    alias parent = Parent;

    private alias toOverload(alias symbol) = FunctionOverload!(
        symbol,
        __traits(getProtection, symbol).toProtection,
        __traits(getLinkage, symbol).toLinkage,
        identifier,
        parent,
    );

    alias overloads = staticMap!(toOverload, __traits(getOverloads, parent, identifier));

    string toString() @safe pure {
        import std.conv: text;
        return text(`Function(`, overloads.stringof, ")");
    }
}

template FunctionsByOverload(alias parent) {
    import mirror.meta.traits : PublicMembers;
    alias FunctionsByOverload = functionsByOverload!(parent, PublicMembers!parent);
}

private template functionsByOverload(alias parent, publicMembers...) {

    import mirror.meta.traits: memberIsRegularFunction;
    import std.meta: Filter, staticMap;

    private alias functionMembers = Filter!(memberIsRegularFunction, publicMembers);

    private template overload(alias S, string I, size_t Idx) {
        alias symbol = S;
        enum identifier = I;
        enum index = Idx;
    }

    template symbolsWithIndex(A...) {
        import std.range: iota;
        import std.meta: aliasSeqOf, staticMap;

        template Result(alias S, size_t I) {
            alias symbol = S;
            enum index = I;
        }

        alias toResult(size_t I) = Result!(A[I], I);

        alias symbolsWithIndex = staticMap!(toResult, aliasSeqOf!(A.length.iota));
    }

    private template memberToOverloads(alias member) {
        private template isPublic(alias S) {
            enum isPublic =  __traits(getProtection, S.symbol) == "public"
                || __traits(getProtection, S.symbol) == "export";
        }
        alias overloadsWithIndex = symbolsWithIndex!(__traits(getOverloads, parent, member.identifier));
        // the reason we need to filter here is that some of the overloads might be private
        private alias overloadSymbols = Filter!(isPublic, overloadsWithIndex);
        private alias toOverload(alias symbol) = overload!(symbol.symbol, member.identifier, symbol.index);
        alias memberToOverloads = staticMap!(toOverload, overloadSymbols);
    }

    private alias toFunction(alias overload) = FunctionOverload!(
        overload.symbol,
        __traits(getProtection, overload.symbol).toProtection,
        __traits(getLinkage, overload.symbol).toLinkage,
        overload.identifier,
        parent,
        overload.index,
    );

    alias functionsByOverload = staticMap!(toFunction, staticMap!(memberToOverloads, functionMembers));
}


/**
   A specific overload of a function.  In most cases it will be
   synonymous with the function symbol since most functions aren't
   overloaded.
 */
template FunctionOverload(
    alias F,
    Protection P = __traits(getProtection, F).toProtection,
    Linkage L = __traits(getLinkage, F).toLinkage,
    string I = __traits(identifier, F),
    alias Parent = Alias!(__traits(parent, F)),
    size_t Idx = 0,
)
{
    import mirror.meta.traits: Parameters;
    import std.traits: RT = ReturnType;

    alias symbol = F;
    alias protection = P;
    alias linkage = L;
    enum identifier = I;
    alias parent = Parent;
    enum index = Idx;

    alias ReturnType = RT!symbol;
    alias parameters = Parameters!F;

    string toString() @safe pure {
        import std.conv: text;
        import std.traits: fullyQualifiedName;
        return text(`Function(`, fullyQualifiedName!symbol, ", ", protection, ", ", linkage, ")");
    }
}
