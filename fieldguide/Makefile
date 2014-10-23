coffee_files := $(wildcard www/js/*.coffee) $(wildcard www/lib/*/js/*.coffee)
js_files     := $(coffee_files:%.coffee=%.js)

mkfile_dir := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))

datasets := $(wildcard datasets/*/)
zips     := $(datasets:datasets/%/=remote/%.zip)

all: js zips
js: $(js_files)
zips: $(zips)

clean:
	rm -f remote/*.zip

# Runs the ->>/=>> preprocessor, then the normal CoffeeScript compiler
%.js: %.coffee
	./action-arrow.rb < $< | coffee -sc > $@

# Runs closure on the .js files just to check for dead code, etc.
closure:
	for js in $(js_files); do \
		echo $$js; \
		closure-compiler --language_in ECMASCRIPT5_STRICT $$js > /dev/null; \
	done

# Zips up each dataset into the zip file to be hosted at our fake remote
remote/%.zip: datasets/%/species.csv
	rm -f $@
	cd datasets/$* && zip -r "$(mkfile_dir)/$@" . \
		-i info.json \
		-i species.csv \
		-i "species/*" \
		-i "features/*"
