module ut.ctfe.functions;


import ut.ctfe;


@("functions")
@safe pure unittest {
    enum mod = module_!("modules.functions");
    mod.functions.shouldBeSameSetAs(
        [
            Function(
                "add1",
                Type("int"),
                [
                    Parameter("int", "i"),
                    Parameter("int", "j"),
                ],
            ),
            Function(
                "add1",
                Type("double"),
                [
                    Parameter("double", "d0"),
                    Parameter("double", "d1"),
                ],
            ),
            Function(
                "withDefault",
                Type("double"),
                [
                    Parameter("double", "d0"),
                    Parameter("double", "d1", "33.3"),
                ],
            ),
        ]
    );
}
