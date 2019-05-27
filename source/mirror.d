module mirror;


struct Module {
    Type[] types;
}


struct Type {
    string name;
}


Module module_(string moduleName)() {
    import std.meta: Alias, staticMap, Filter;

    mixin(`import `, moduleName, `;`);
    alias mod = Alias!(mixin(moduleName));

    enum notObject(string name) = name != "object";
    alias memberNames = Filter!(notObject, __traits(allMembers, mod));

    enum toType(string name) = Type(name);
    alias types = staticMap!(toType, memberNames);

    Module ret;

    static foreach(type; types)
        ret.types ~= type;

    return ret;
}


template ModuleTemplate(string name) {
    import std.meta: Filter, staticMap, Alias;

    mixin(`import `, name, `;`);
    alias mod = Alias!(mixin(name));

    enum notObject(string name) = name != "object";
    alias memberNames = Filter!(notObject, __traits(allMembers, mod));

    alias member(string name) = Alias!(mixin(name));
    alias Types = staticMap!(member, memberNames);
}
