/**
   This module provides the CTFE variant of compile-time reflection,
   allowing client code to use regular D functions (as opposed to
   template metaprogramming) to operate on the contents of a D module
   using string mixins.
 */

module mirror.ctfe;


/**
   Returns compile-time reflection information about a D module.
 */
Module module_(string moduleName)() {
    import mirror.meta: ModuleTemplate = Module;
    import std.meta: staticMap;

    Module ret;
    ret.identifier = moduleName;

    alias module_ = ModuleTemplate!moduleName;

    template toKind(T) {
        import mirror.traits: FundamentalType;
        alias U = FundamentalType!T;
        static if(is(U == enum))
            enum toKind = Aggregate.Kind.enum_;
        else static if(is(U == struct))
            enum toKind = Aggregate.Kind.struct_;
        else static if(is(U == class))
            enum toKind = Aggregate.Kind.class_;
        else static if(is(U == interface))
            enum toKind = Aggregate.Kind.interface_;
        else
            static assert(false, "Unknown kind " ~ T.stringof);
    }

    enum toAggregate(T) = Aggregate(T.stringof, toKind!T);
    ret.aggregates = [ staticMap!(toAggregate, module_.Aggregates) ];
    ret.allAggregates = [ staticMap!(toAggregate, module_.AllAggregates) ];

    enum toVariable(alias V) = Variable(V.Type.stringof, V.identifier);
    ret.variables = [ staticMap!(toVariable, module_.Variables) ];

    template toFunction(alias F) {

        import std.range: iota;
        import std.meta: aliasSeqOf;
        import std.traits: ReturnType, Parameters, ParameterDefaults, ParameterIdentifierTuple;

        template toDefault(size_t i) {
            static if(is(ParameterDefaults!(F.symbol)[i] == void))
                enum toDefault = "";
            else
                enum toDefault = ParameterDefaults!(F.symbol)[i].stringof;
        }

        template toParameter(size_t i) {
            import std.traits: ParameterStorageClassTuple;

            enum toParameter = Parameter(
                Parameters!(F.symbol)[i].stringof,
                ParameterIdentifierTuple!(F.symbol)[i],
                toDefault!i,
                ParameterStorageClassTuple!(F.symbol)[i],
            );
        }

        enum toFunction = Function(
            moduleName,
            F.index,
            F.identifier,
            Type(ReturnType!(F.symbol).stringof),
            [staticMap!(toParameter, aliasSeqOf!(Parameters!(F.symbol).length.iota))],
        );
    }

    ret.functionsByOverload = [ staticMap!(toFunction, module_.FunctionsByOverload) ];

    template withIndex(A...) {
        import std.range: iota;
        import std.meta: aliasSeqOf;

        template overload(alias F, size_t I) {
            alias symbol = F.symbol;
            enum identifier = F.identifier;
            enum index = I;
        }

        alias toOverload(size_t I) = overload!(A[I], I);

        alias withIndex = staticMap!(toOverload, aliasSeqOf!(A.length.iota));
    }

    template toOverloaded(alias F) {
        enum toOverloaded = OverloadSet(
            F.identifier,
            [ staticMap!(toFunction, withIndex!(F.overloads)) ]
        );
    }

    ret.functionsBySymbol = [ staticMap!(toOverloaded, module_.FunctionsBySymbol) ];

    return ret;
}


/**
   A D module.
 */
struct Module {
    string identifier;
    Aggregate[] aggregates;
    Aggregate[] allAggregates;  // includes all function return types
    Variable[] variables;
    Function[] functionsByOverload;
    OverloadSet[] functionsBySymbol;
}


/**
   A user-defined type (struct, class, or enum).
 */
struct Aggregate {

    enum Kind {
        enum_,
        struct_,
        class_,
        interface_,
    }

    string identifier;
    Kind kind;
    Variable[] fields;
    Function[] functions;
    // UDAs?
}

struct Type {
    string identifier;
    // UDAs?
    string toString() @safe @nogc pure nothrow const {
        return identifier;
    }
}

/// A variable
struct Variable {
    string type;
    string identifier;
    // UDAs?
}


/// A set of function overloads
struct OverloadSet {
    string identifier;
    Function[] overloads;
}

/// A function
struct Function {
    string moduleName;
    int overloadIndex;
    string identifier;
    Type returnType;
    Parameter[] parameters;
    // TODO: @safe, pure, nothrow, etc.
    // TODO: UDAs


    string importMixin() @safe pure nothrow const {
        return `static import ` ~ moduleName ~ `;`;
    }

    string callMixin(A...)(auto ref A args) {
        import std.conv: text;
        import std.array: join;
        import std.algorithm: map;

        string[] argTexts;

        static foreach(arg; args) {
            argTexts ~= arg.text;
        }

        return text(
            moduleName, `.`, identifier, `(`,
            argTexts.map!text.join(`, `),
            `)`);
    }

    string fullyQualifiedName() @safe pure nothrow const {
        return moduleName ~ "." ~ identifier;
    }

    string pointerMixin() @safe pure nothrow const {
        import std.conv: text;
        return text(`&__traits(getOverloads, `, moduleName, `, "`, identifier, `")[`, overloadIndex, `]`);
    }
}

auto pointer(Function function_)() {
    mixin(`static import `, function_.moduleName, `;`);

    alias overloads = __traits(
        getOverloads,
        mixin(function_.moduleName),
        function_.identifier
    );

    return &overloads[function_.overloadIndex];
}


/// A function parameter
struct Parameter {
    import std.traits: ParameterStorageClass;

    string type;
    string identifier;
    string default_;  /// default value, if any
    ParameterStorageClass storageClass;
}


// TODO:
// * Module {c,d}tors
// * Unit tests
// * Class hierachies
// * Aliases?
