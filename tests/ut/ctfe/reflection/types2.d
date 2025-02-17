module ut.ctfe.reflection.types2;


import ut;
import mirror.ctfe.reflection2;


@("empty")
@safe pure unittest {
    module_!"modules.empty".should == Module("modules.empty");
}

@("imports")
@safe pure unittest {
    module_!"modules.imports".should == Module("modules.imports");
}
