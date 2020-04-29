dpp_version = 0.4.0
dpp_pkg_dir = $(HOME)/.dub/packages/dpp-$(dpp_version)
dpp_lock = $(dpp_pkg_dir)/dpp.lock
dpp_dir = $(dpp_pkg_dir)/dpp
dpp = $(dpp_dir)/bin/d++

PYTHON_INCLUDE_DIR = $(shell python -c 'from distutils.sysconfig import get_python_inc; print(get_python_inc())')

.PHONY: test
test: python_wrap_ctfe.so
	PYTHONPATH=$(shell pwd) pytest -s -vv

python_wrap_ctfe.so: libpython_wrap_ctfe.so
	cp $< $@

.PHONY: libpython_wrap_ctfe.so
libpython_wrap_ctfe.so: source/python/package.d
	dub build -q

source/python/package.d: source/python/package.dpp $(dpp)
	$(dpp) --preprocess-only --include-path $(PYTHON_INCLUDE_DIR) $<

$(dpp): $(dpp_lock)
	cd $(dpp_dir) && dub build -q --build=release

$(dpp_lock):
	dub fetch dpp --version=$(dpp_version)
