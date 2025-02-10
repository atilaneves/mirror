/**
   This module provides the CTFE variant of compile-time reflection,
   allowing client code to use regular D functions (as opposed to
   template metaprogramming) to operate on the contents of a D module
   using string mixins.
 */
module mirror.ctfe.reflection2;


Module module_(string moduleName)() {

    import std.traits: ReturnType; // sigh

    Module mod;

    mixin(`static import `, moduleName, `;`);
    alias module_ = mixin(moduleName);

    string fqn(string member) {
        return moduleName ~ `.` ~ member;
    }

    static foreach(memberName; __traits(allMembers, module_)) {
        static if(is(typeof(mixin(fqn(memberName))) == function)) {
            static foreach(i, overload; __traits(getOverloads, module_, memberName)) {

                mod.functionsByOverload ~= Function(
                    moduleName,
                    i,
                    memberName,
                    type!(ReturnType!overload),
                );
            }
        }
    }

    return mod;
}


struct Module {
    string identifier;
    Function[] functionsByOverload;
}


struct Function {
    string moduleName;
    size_t overloadIndex;
    string identifier;
    Type returnType;

    string importMixin() @safe pure nothrow scope const {
        return "static import " ~ moduleName ~ ";";
    }

    string symbolMixin() @safe pure nothrow scope const {
        import std.conv: text;
        return text(`__traits(getOverloads, `,  moduleName,  `, "`,  identifier,  `")[`, overloadIndex, `]`);
    }

    /**
       Do NOT use this to get the symbol, it will fail for overloads
       other than the first one.
     */
    string fullyQualifiedName() @safe pure nothrow scope const {
        return moduleName ~ "." ~ identifier;
    }
}


struct Type {
    string fullyQualifiedName;
}

Type type(T)() {
    import std.traits: fullyQualifiedName;
    return Type(fullyQualifiedName!T);
}
