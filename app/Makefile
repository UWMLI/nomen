coffee_files := $(wildcard www/js/*.coffee) $(wildcard www/lib/*/js/*.coffee)
js_files     := $(coffee_files:%.coffee=%.js)

mkfile_dir := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))

datasets := $(wildcard datasets/*/)

all: js
js: $(js_files)

clean:
	rm -f $(js_files)

# Runs the ->>/=>> preprocessor, then the normal CoffeeScript compiler
%.js: %.coffee
	./action-arrow.rb < $< | coffee -sc > $@

# Runs closure on the .js files just to check for dead code, etc.
closure: $(js_files)
	for js in $(js_files); do \
		echo $$js; \
		closure-compiler --language_in ECMASCRIPT5_STRICT $$js > /dev/null; \
	done
