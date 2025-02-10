/**
   This module provides the CTFE variant of compile-time reflection,
   allowing client code to use regular D functions (as opposed to
   template metaprogramming) to operate on the contents of a D module
   using string mixins.
 */
module mirror.ctfe.reflection2;


/*
  TODO:

  * Remove std.traits dependency (ugh, templates) by copying what
  the various functions do.

  * Go over the whole list of built-in traits and expose all of it.
*/


Module module_(string moduleName)() {

    // This one is too annoying to inline
    import std.traits: ParameterDefaults;

    Module mod;

    mixin(`static import `, moduleName, `;`);
    alias module_ = mixin(moduleName);

    string fqn(string member) {
        return moduleName ~ `.` ~ member;
    }

    static foreach(memberName; __traits(allMembers, module_)) {
        static if(is(typeof(mixin(fqn(memberName))) == function)) {
            static foreach(i, overload; __traits(getOverloads, module_, memberName)) {{

                static if(is(typeof(overload) R == return))
                    enum returnType = type!R;
                else
                    static assert(false, "Cannot get return type of " ~ __traits(identifier, overload));

                Parameter[] parameters;
                static if(is(typeof(overload) Ps == __parameters)) {
                    static foreach(p; 0 .. Ps.length) {{

                        static if(is(typeof(__traits(identifier, Ps[p .. p + 1]))))
                            enum paramIdentifier = __traits(identifier, Ps[p .. p + 1]);
                        else
                            enum paramIdentifier = Ps[i].stringof;

                        parameters ~= Parameter(
                            type!(Ps[p]),
                            paramIdentifier,
                            phobosPSC([__traits(getParameterStorageClasses, overload, p)]),
                            ParameterDefaults!overload[p].stringof,
                        );
                    }}
                } else
                    static assert(false, "Cannot get parameters of " ~ __traits(identifier, overload));

                mod.functionsByOverload ~= Function(
                    moduleName ~ "." ~ memberName,
                    i,
                    returnType,
                    parameters,
                );
            }}
        }
    }

    return mod;
}

// look ma, no templates
private auto phobosPSC(string[] storageClasses) @safe pure nothrow {
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

}


struct Type {
    string fullyQualifiedName;
}

Type type(T)() {
    import std.traits: fullyQualifiedName;
    return Type(fullyQualifiedName!T);
}


struct Parameter {
    import std.traits: PSC = ParameterStorageClass;

    Type type;
    string identifier;
    PSC storageClass;
    string default_;
}
