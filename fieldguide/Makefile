coffee_files := $(wildcard www/js/*.coffee) $(wildcard www/lib/*/js/*.coffee)
js_files     := $(coffee_files:%.coffee=%.js)

mkfile_dir := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))

datasets := plants pokemon
zips     := $(datasets:%=%.zip)

all: $(js_files) $(zips)

clean:
	rm -f $(zips)
	rm -rf pokemon/

%.js: %.coffee
	coffee -c $<

plants.zip:
	rm -f $@
	cd $(@:%.zip=%) && zip -rq "$(mkfile_dir)/$@" .

pokemon.zip: pokemon.rb
	./pokemon.rb
	rm -f $@
	cd pokemon && zip -rq "$(mkfile_dir)/$@" .
