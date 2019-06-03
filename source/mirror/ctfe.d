module mirror.ctfe;


Module module_(string moduleName)() {
    import mirror.meta: ModuleTemplate = Module;
    import std.meta: staticMap;

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

    return ret;
}


struct Module {
    Type[] types;
    Variable[] variables;
}


struct Type {
    string name;
}


struct Variable {
    string type;
    string name;
}
