module ut.ctfe.reflection.runtime;


import ut.ctfe.reflection;


@("registerModule.runtime")
unittest {
    import modules.runtime: rtModuleInfo = gModuleInfo;
    static immutable ctModuleInfo = module_!"modules.runtime";
    rtModuleInfo.fullyQualifiedName.should == ctModuleInfo.fullyQualifiedName;
    rtModuleInfo.functionsBySymbol.length.should == ctModuleInfo.functionsBySymbol.length;
}
