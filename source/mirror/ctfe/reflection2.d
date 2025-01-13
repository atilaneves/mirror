/**
   This module provides the CTFE variant of compile-time reflection,
   allowing client code to use regular D functions (as opposed to
   template metaprogramming) to operate on the contents of a D module
   using string mixins.
 */
module mirror.ctfe.reflection2;


Module module_(string moduleName)() {

    Module mod;

    mixin(`static import `, moduleName, `;`);
    mixin(`alias module_ = `, moduleName, `;`);

    string fqn(string member) {
        return moduleName ~ `.` ~ member;
    }

    static foreach(member; __traits(allMembers, module_)) {
        static if(is(typeof(mixin(fqn(member))) == function)) {
            static foreach(i, overload; __traits(getOverloads, module_, member)) {
                mod.functionsByOverload ~= Function("modules.functions", i, member);
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
    string module_;
    size_t overloadIndex;
    string identifier;

    string importMixin() @safe pure nothrow scope const {
        return "static import " ~ module_ ~ ";";
    }

    string fullyQualifiedName() @safe pure nothrow scope const {
        return module_ ~ "." ~ identifier;
    }
}
