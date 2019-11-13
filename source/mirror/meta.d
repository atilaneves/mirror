/**
   This module provides the template metaprogramming variant of compile-time
   reflection, allowing client code to do type-level computations on the
   contents of a D module.
 */
module mirror.meta;


import std.meta: Alias;


/**
   Compile-time information on a D module.
 */
template Module(string moduleName) {

    import mirror.traits: RecursiveTypeTree, RecursiveFieldTypes, FundamentalType, PublicMembers;
    import std.meta: Alias, NoDuplicates;

    mixin(`import `, moduleName, `;`);
    private alias mod = Alias!(mixin(moduleName));

    private alias publicMembers = PublicMembers!mod;

    /// User-defined structs/classes
    alias Aggregates = aggregates!publicMembers;

    /// User-defined structs/classes and all types contained in them
    alias AggregatesTree = RecursiveTypeTree!Aggregates;

    /// Global variables/enums
    alias Variables = variables!publicMembers;

    /// List of functions by symbol - contains overloads for each entry
    alias FunctionsBySymbol = functionsBySymbol!(mod, publicMembers);

    /// List of functions by overload - each overload is a separate entry
    alias FunctionsByOverload = functionsByOverload!(mod, publicMembers);

    alias AllFunctionReturnTypes = allFunctionReturnTypes!FunctionsByOverload;
    alias AllFunctionReturnTypesTree = RecursiveTypeTree!AllFunctionReturnTypes;

    alias AllFunctionParameterTypes = allFunctionParameterTypes!FunctionsByOverload;
    alias AllFunctionParameterTypesTree = RecursiveTypeTree!AllFunctionParameterTypes;

    /**
       All aggregates, including explicitly defined and appearing in
       function signatures
    */
    alias AllAggregates = NoDuplicates!(AggregatesTree, AllFunctionReturnTypesTree, AllFunctionParameterTypesTree);
}


package template allFunctionReturnTypes(functions...) {

    import mirror.traits: FundamentalType;
    import std.traits: ReturnType;
    import std.meta: staticMap, NoDuplicates;

    private alias symbol(alias F) = F.symbol;

    alias allFunctionReturnTypes =
        NoDuplicates!(staticMap!(FundamentalType,
                                 staticMap!(ReturnType,
                                            staticMap!(symbol, functions))));
}

package template allFunctionParameterTypes(functions...) {

    import mirror.traits: FundamentalType;
    import std.traits: Parameters;
    import std.meta: staticMap, NoDuplicates;

    private alias symbol(alias F) = F.symbol;

    alias allFunctionParameterTypes =
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
    import std.meta: staticMap, Filter;

    private enum isVariable(alias member) = is(typeof(member.symbol));
    private alias toVariable(alias member) = Variable!(typeof(member.symbol), __traits(identifier, member.symbol));
    alias variables = staticMap!(toVariable, Filter!(isVariable, publicMembers));
}

/**
   A global variable.
 */
template Variable(T, string N) {
    alias Type = T;
    enum name = N;
}


private template functionsBySymbol(alias parent, publicMembers...) {

    import mirror.traits: memberIsRegularFunction;
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


package template functionsByOverload(alias parent, publicMembers...) {

    import mirror.traits: memberIsRegularFunction;
    import std.meta: Filter, staticMap;

    private alias functionMembers = Filter!(memberIsRegularFunction, publicMembers);

    private template overload(alias S, string I) {
        alias symbol = S;
        enum identifier = I;
    }

    private template memberToOverloads(alias member) {
        private alias overloadSymbols = __traits(getOverloads, parent, member.identifier);
        private alias toOverload(alias symbol) = overload!(symbol, member.identifier);
        alias memberToOverloads = staticMap!(toOverload, overloadSymbols);
    }

    private alias toFunction(alias overload) = FunctionOverload!(
        overload.symbol,
        __traits(getProtection, overload.symbol).toProtection,
        __traits(getLinkage, overload.symbol).toLinkage,
        overload.identifier,
        parent,
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
)
{
    import mirror.traits: Parameters;
    import std.traits: RT = ReturnType;

    alias symbol = F;
    alias protection = P;
    alias linkage = L;
    enum identifier = I;
    alias parent = Parent;

    alias ReturnType = RT!symbol;
    alias parameters = Parameters!F;

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
