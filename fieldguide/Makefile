coffee_files := $(wildcard www/js/*.coffee) $(wildcard www/lib/*/js/*.coffee)
js_files     := $(coffee_files:%.coffee=%.js)

sass_files := $(wildcard www/css/*.s[ac]ss)
css_files  := $(patsubst %.sass,%.css,$(patsubst %.scss,%.css,$(sass_files)))

all: $(js_files) $(css_files)

%.js: %.coffee
	coffee -c $<

%.css: %.sass
	sass $< $@

%.css: %.scss
	sass $< $@
