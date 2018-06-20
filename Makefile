.PHONY: build publish

build:
	gem build reveal.rb

publish:
	gem push *.gem
