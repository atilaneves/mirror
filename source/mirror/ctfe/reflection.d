/**
   This module provides the CTFE variant of compile-time reflection,
   allowing client code to use regular D functions (as opposed to
   template metaprogramming) to operate on the contents of a D module
   using string mixins.
 */
module mirror.ctfe.reflection;


/**
   Returns compile-time reflection information about a D module.
 */
Module module_(string moduleName)() {
    import mirror.meta.reflection: ModuleTemplate = Module;
    import mirror.meta.traits: Fields;
    import std.meta: staticMap;
    import std.traits: fullyQualifiedName;

    Module ret;
    ret.identifier = moduleName;

    alias module_ = ModuleTemplate!moduleName;

    template toKind(T) {
        import mirror.meta.traits: FundamentalType;
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
            static assert(false, "Unknown kind " ~ fullyQualifiedName!T);
    }

    enum toVariable(alias V) = Variable(fullyQualifiedName!(V.Type), V.identifier);
    ret.variables = [ staticMap!(toVariable, module_.Variables) ];

    enum toAggregate(T) = Aggregate(
        fullyQualifiedName!T,
        toKind!T,
        [ staticMap!(toVariable, Fields!T)],
    );
    ret.aggregates    = [ staticMap!(toAggregate, module_.Aggregates)    ];
    ret.allAggregates = [ staticMap!(toAggregate, module_.AllAggregates) ];


    template toFunction(alias F) {
        import mirror.meta.traits: Parameters;
        import std.traits: ReturnType;

        template toDefault(alias Default) {
            static if(is(Default == void))
                enum toDefault = "";
            else
                enum toDefault = Default.stringof;
        }

        enum toParameter(alias P) = Parameter(
            type!(P.Type),
            P.identifier,
            toDefault!(P.Default),
            P.storageClass
        );

        enum toFunction = Function(
            moduleName,
            F.index,
            F.identifier,
            type!(ReturnType!(F.symbol)),
            [ staticMap!(toParameter, Parameters!(F.symbol)) ],
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
    Function[] functions;  // TODO
    // TODO: attributes
}


Type type(T)() {
    import std.traits: fullyQualifiedName;
    return Type(fullyQualifiedName!T, T.sizeof);
}


struct Type {
    string name;
    size_t size;
    // UDAs?
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


/// A function. Each of these describes only one overload.
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

/**
   Returns a pointer to the function described
   by `function_`.
 */
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

    Type type;
    string identifier;
    string default_;  /// default value, if any
    ParameterStorageClass storageClass;
}
