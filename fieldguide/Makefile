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

%.pp.coffee: %.coffee
	./action-arrow.rb < $< > $@
%.pp.js: %.pp.coffee
	coffee -c $<
%.js: %.pp.js
	cp $< $@
	closure-compiler --language_in ECMASCRIPT5_STRICT $@ > /dev/null

remote/%.zip: datasets/%/species.csv
	rm -f $@
	cd datasets/$* && zip -r "$(mkfile_dir)/$@" . \
		-i info.json \
		-i species.csv \
		-i "species/*" \
		-i "features/*"
