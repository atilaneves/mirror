module mirror.ctfe;


Module module_(string moduleName)() {
    import mirror.meta: ModuleTemplate = Module;
    import std.meta: staticMap;

    Module ret;

    alias module_ = ModuleTemplate!moduleName;

    enum toType(T) = Type(__traits(identifier, T));
    ret.types = [ staticMap!(toType, module_.Types) ];

    enum toVariable(alias V) = Variable(V.Type.stringof, V.name);
    ret.variables = [ staticMap!(toVariable, module_.Variables) ];

    template toFunction(alias F) {

        import std.range: iota;
        import std.meta: aliasSeqOf;
        import std.traits: ReturnType, Parameters, ParameterDefaults, ParameterIdentifierTuple;

        template toDefault(size_t i) {
            static if(is(ParameterDefaults!F[i] == void))
                enum toDefault = "";
            else
                enum toDefault = ParameterDefaults!F[i].stringof;
        }

        enum toParameter(size_t i) = Parameter(
            Parameters!F[i].stringof,
            ParameterIdentifierTuple!F[i],
            toDefault!i,
        );

        enum toFunction = Function(
            __traits(identifier, F),
            ReturnType!F.stringof,
            [staticMap!(toParameter, aliasSeqOf!(Parameters!F.length.iota))],
        );
    }
    ret.functions = [ staticMap!(toFunction, module_.Functions) ];

    return ret;
}


struct Module {
    Type[] types;
    Variable[] variables;
    Function[] functions;
}


struct Type {
    string name;
}


struct Variable {
    string type;
    string name;
}


struct Function {
    string name;
    string returnType;
    Parameter[] parameters;
}


struct Parameter {
    string type;
    string name;
    string default_;
}
