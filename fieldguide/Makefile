coffee_files := $(wildcard www/js/*.coffee) $(wildcard www/lib/*/js/*.coffee)
js_files     := $(coffee_files:%.coffee=%.js)

all: $(js_files) plants.zip

%.js: %.coffee
	coffee -c $<

plants.zip:
	rm -f plants.zip
	zip -r $@ plants/
