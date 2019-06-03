module mirror.ctfe;


struct Module {
    Type[] types;
}


struct Type {
    string name;
}


Module module_(string moduleName)() {
    import mirror.meta: ModuleTemplate;
    import std.meta: staticMap;

    alias module_ = ModuleTemplate!moduleName;
    enum toType(T) = Type(__traits(identifier, T));
    alias types = staticMap!(toType, module_.Types);

    Module ret;

    static foreach(type; types)
        ret.types ~= type;

    return ret;
}
