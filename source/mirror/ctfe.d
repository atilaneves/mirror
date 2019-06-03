module mirror.ctfe;


Module module_(string moduleName)() {
    import mirror.meta: ModuleTemplate = Module;
    import std.meta: staticMap;
    import std.traits: ReturnType, Parameters, ParameterIdentifierTuple;

    Module ret;

    alias module_ = ModuleTemplate!moduleName;

    enum toType(T) = Type(__traits(identifier, T));
    alias types = staticMap!(toType, module_.Types);
    static foreach(type; types)
        ret.types ~= type;

    enum toVariable(alias V) = Variable(V.Type.stringof, V.name);
    alias variables = staticMap!(toVariable, module_.Variables);
    static foreach(var; variables)
        ret.variables ~= var;

    template toFunction(alias F) {

        import std.range: iota;
        import std.meta: aliasSeqOf;

        enum toParameter(size_t i) = Parameter(
            Parameters!F[i].stringof,
            ParameterIdentifierTuple!F[i],
        );

        enum toFunction = Function(
            __traits(identifier, F),
            ReturnType!F.stringof,
            [staticMap!(toParameter, aliasSeqOf!(Parameters!F.length.iota))],
        );
    }

    alias functions = staticMap!(toFunction, module_.Functions);
    static foreach(func; functions)
        ret.functions ~= func;

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
}
