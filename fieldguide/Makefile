coffee_files := $(wildcard www/js/*.coffee) $(wildcard www/lib/*/js/*.coffee)
js_files     := $(coffee_files:%.coffee=%.js)

mkfile_dir := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))

datasets := plants pokemon colors
zips     := $(datasets:%=%.zip)

all: js zips

js: $(js_files)

zips: $(zips)

clean:
	rm -f $(zips)
	rm -rf pokemon/

%.js: %.coffee
	coffee -c $<

%.zip: %/species.csv
	rm -f $@
	cd $(@:%.zip=%) && zip -r "$(mkfile_dir)/$@" . \
		-i info.json \
		-i species.csv \
		-i "species/*" \
		-i "features/*"

pokemon/species.csv:
	cd pokemon && cabal run
