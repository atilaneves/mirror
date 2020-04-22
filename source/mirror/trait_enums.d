/**
   Destringifies traits avaiable from the compiler or std.traits
   for getter type safety.
 */
module mirror.trait_enums;


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
