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
    ret.name = moduleName;

    alias module_ = ModuleTemplate!moduleName;

    enum toType(T) = Aggregate(__traits(identifier, T));
    ret.aggregates = [ staticMap!(toType, module_.Aggregates) ];

    enum toVariable(alias V) = Variable(V.Type.stringof, V.name);
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
            F.identifier,
            Type(ReturnType!(F.symbol).stringof),
            [staticMap!(toParameter, aliasSeqOf!(Parameters!(F.symbol).length.iota))],
        );
    }
    ret.functions = [ staticMap!(toFunction, module_.Functions) ];

    return ret;
}


/**
   A D module.
 */
struct Module {
    string name;
    Aggregate[] aggregates;
    Variable[] variables;
    Function[] functions;
}


/**
   A user-defined type (struct, class, or enum).
 */
struct Aggregate {
    string name;
    Variable[] fields;
    Function[] functions;
    // UDAs?
}

struct Type {
    string name;
    // UDAs?
}

/// A variable
struct Variable {
    string type;
    string name;
    // UDAs?
}


/// A free function
struct Function {
    string name;
    Type returnType;
    Parameter[] parameters;
    // UDAs?
    // Function attributes?
}


/// A function parameter
struct Parameter {
    import std.traits: ParameterStorageClass;

    string type;
    string name;
    string default_;  /// default value, if any
    ParameterStorageClass storageClass;
}


// TODO:
// * Module {c,d}tors
// * Unit tests
// * Class hierachies
// * Aliases?
