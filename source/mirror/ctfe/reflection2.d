/**
   This module provides the CTFE variant of compile-time reflection,
   allowing client code to use regular D functions (as opposed to
   template metaprogramming) to operate on the contents of a D module
   using string mixins.
 */
module mirror.ctfe.reflection2;


/*
  TODO:

  * Remove std.traits.fullyQualifiedName dependency.

  * Go over the whole list of built-in traits and expose all of it.

  * Add static constructors to the module struct.

  * Add unit tests to the module struct.

  * Functions by symbol and not just by overload.

  * Function attributes (@safe, etc.)

  * Function UDAs.

  * When doing aggregates, include function return types and
    parameters, see the old `functions.allAggregates` test.
*/


Module module_(string moduleName)() {

    import std.algorithm: countUntil;
    import std.traits: fullyQualifiedName;

    Module mod;
    mod.identifier = moduleName;

    mixin(`static import `, moduleName, `;`);
    alias module_ = mixin(moduleName);

    static fqn(string memberName) {
        return moduleName ~ `.` ~ memberName;
    }

    static foreach(memberName; __traits(allMembers, module_)) {{

        static if(isVisible!(moduleName, memberName)) {

            alias symbol = mixin(fqn(memberName));

            static if(is(typeof(symbol) == function) && isRegularFunction(memberName)) {
                static foreach(i, overload; __traits(getOverloads, module_, memberName)) {{

                    static if(is(typeof(overload) R == return))
                        enum returnType = Type(fullyQualifiedName!R);
                    else
                        static assert(false, "Cannot get return type of " ~ __traits(identifier, overload));

                    Parameter[] parameters;
                    static if(is(typeof(overload) Ps == __parameters)) {
                        static foreach(p; 0 .. Ps.length) {{

                            static if(is(typeof(__traits(identifier, Ps[p .. p + 1]))))
                                enum paramIdentifier = __traits(identifier, Ps[p .. p + 1]);
                            else
                                enum paramIdentifier = Ps[i].stringof;

                            enum paramString = Ps[p .. p + 1].stringof;
                            enum assignIndex = paramString.countUntil(`=`);
                            static if(assignIndex == -1)
                                enum default_ = "";
                            else {
                                // paramString will be something like:
                                // `(T id = val)`
                                // we want default_ in this case to be "val"
                                static assert(paramString[assignIndex + 1] == ' ');
                                enum default_ = paramString[assignIndex + 2 .. $-1];
                            }

                            parameters ~= Parameter(
                                Type(fullyQualifiedName!(Ps[p])),
                                paramIdentifier,
                                phobosPSC([__traits(getParameterStorageClasses, overload, p)]),
                                default_,
                            );
                        }}
                    } else
                        static assert(false, "Cannot get parameters of " ~ __traits(identifier, overload));

                    mod.functionsByOverload ~= Function(
                        moduleName ~ "." ~ memberName,
                        i,
                        returnType,
                        parameters,
                        __traits(getVisibility, overload),
                        __traits(getLinkage, overload),
                    );
                }}
            } else static if(is(symbol) && isUDT!symbol) {
                mod.aggregates ~= Aggregate(
                    fqn(memberName),
                    Aggregate.toKind!symbol,
                );
            } else static if(isVariable!symbol) {
                mod.variables ~= Variable(
                    Type(fullyQualifiedName!(typeof(symbol))),
                    fqn(memberName),
                );
            }
        }
    }}

    mod.allAggregates = mod.aggregates;  // FIXME

    return mod;
}

private bool isVisible(string moduleName, string memberName)() {
    mixin(`static import `, moduleName, `;`);
    enum fqn = moduleName ~ "." ~ memberName;
    static if(__traits(compiles, mixin(`{ alias symbol = `, fqn, `; }`))) {
        alias symbol = mixin(fqn);
        static if(__traits(compiles,  __traits(getVisibility, symbol))) {
            enum vis = __traits(getVisibility, symbol);
            return vis == "public" || vis == "export";
        } else
            return true; // basic type
    } else
        return false;
}

private bool isRegularFunction(in string memberName) @safe pure nothrow {
    import std.algorithm: startsWith;
        return
            !memberName.startsWith("_sharedStaticCtor") &&
            !memberName.startsWith("_staticCtor");
}

private bool isUDT(Type)() {
    return
        is(Type == enum) ||
        is(Type == struct) ||
        is(Type == class) ||
        is(Type == interface) ||
        is(Type == union)
        ;
}

// look ma, no templates
private auto phobosPSC(in string[] storageClasses) @safe pure nothrow {
    import std.traits: PSC = ParameterStorageClass;

    auto ret = PSC.none;

    foreach(storageClass; storageClasses) {
        final switch(storageClass) with(PSC) {
            case "scope":  ret |= scope_;  break;
            case "in":     ret |= in_;     break;
            case "out":    ret |= out_;    break;
            case "ref":    ret |= ref_;    break;
            case "lazy":   ret |= lazy_;   break;
            case "return": ret |= return_; break;
        }
    }

    return ret;
}

struct Module {
    string identifier;
    Function[] functionsByOverload;
    Aggregate[] aggregates;     /// only the ones defined in the module.
    Aggregate[] allAggregates;  /// includes all function return types.
    Variable[] variables;
}


struct Function {
    /**
       Do NOT use this to get the symbol, it will fail for overloads
       other than the first one.
     */
    string fullyQualifiedName;
    size_t overloadIndex;
    Type returnType;
    Parameter[] parameters;
    string visibilityStr;
    string linkageStr;

    string importMixin() @safe pure nothrow scope const {
        return "static import " ~ moduleName ~ ";";
    }

    string symbolMixin() @safe pure nothrow scope const {
        import std.conv: text;
        return text(`__traits(getOverloads, `,  moduleName,  `, "`,  identifier,  `")[`, overloadIndex, `]`);
    }

    string moduleName() @safe pure nothrow scope const {
        import std.string: split, join;
        return fullyQualifiedName.split(".")[0 .. $-1].join(".");
    }

    string identifier() @safe pure nothrow scope const {
        import std.string: split, join;
        return fullyQualifiedName.split(".")[$-1];
    }

    Visibility visibility() @safe pure scope const {
        switch(visibilityStr) with(Visibility) {
            default: throw new Exception("Unknown visibility " ~ visibilityStr);
                static foreach(vis; ["public", "private", "protected", "export", "package"]) {
                case vis: return mixin(vis ~ "_");
            }
       }
    }

    Linkage linkage() @safe pure scope const {
        switch(linkageStr) with(Linkage) {
            default: throw new Exception("Unknown linkage " ~ linkageStr);
            case "D": return D;
            case "C": return C;
            case "C++": return Cplusplus;
            case "Windows": return Windows;
            case "ObjectiveC": return ObjectiveC;
            case "System": return System;
        }
    }

}


struct Type {
    string fullyQualifiedName;
}


struct Parameter {
    import std.traits: PSC = ParameterStorageClass;

    Type type;
    string identifier;
    PSC storageClass;
    string default_;
}

enum Visibility {
    public_,
    private_,
    protected_,
    export_,
    package_,
}


enum Linkage {
    D,
    C,
    Cplusplus,
    Windows,
    ObjectiveC,
    System,
}

struct Aggregate {

    enum Kind {
        enum_,
        struct_,
        class_,
        interface_,
        union_,
    }

    string fullyQualifiedName;
    Kind kind;

    static Kind toKind(T)() {
        with(Kind) {
            static foreach(k; ["enum", "struct", "class", "interface", "union"]) {
                static if(mixin(`is(T == `, k, `)`))
                    return mixin(k ~ "_");
            }
        }
    }

    string moduleName() @safe pure nothrow scope const {
        import std.string: split, join;
        return fullyQualifiedName.split(".")[0 .. $-1].join(".");
    }

    string identifier() @safe pure nothrow scope const {
        import std.string: split, join;
        return fullyQualifiedName.split(".")[$-1];
    }
}

struct Variable {
    Type type;
    string fullyQualifiedName;
}

bool isVariable(alias symbol)() {
    return
        is(typeof(symbol))
        && !is(typeof(symbol) == function)
        && !is(typeof(symbol) == void)  // can happen with templates
        && is(typeof(symbol.init))
        ;
}
