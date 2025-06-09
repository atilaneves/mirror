module ut.ctfe.reflection.runtime;


import ut.ctfe.reflection;


@("registerModule.runtime")
@safe pure unittest {
    import modules.runtime: rtModuleInfo = gModuleInfo;
    static immutable ctModuleInfo = module_!"modules.runtime";
    rtModuleInfo.fullyQualifiedName.should == ctModuleInfo.fullyQualifiedName;
    rtModuleInfo.functionsBySymbol.length.should == ctModuleInfo.functionsBySymbol.length;
}

@("moduleInfos")
@safe unittest { // not pure because accessing a global
    allModuleInfos.length.should == 1;
    allModuleInfos[0].fullyQualifiedName.should == "modules.runtime";
}
