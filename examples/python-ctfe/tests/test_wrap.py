def test_add1():
    from python_wrap_ctfe import add1
    assert add1(1, 1) == 3
    assert add1(1, 2) == 4
    assert add1(2, 2) == 5
