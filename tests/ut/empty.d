module ut.empty;


import ut;


@safe pure unittest {
    reflect!"modules.empty".should ==
        Module();
}
