module ut.empty;


import ut;


@("empty")
@safe pure unittest {
    module_!"modules.empty".should == Module();
}
