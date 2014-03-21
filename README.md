# reveal.rb

[reveal.js](https://github.com/hakimel/reveal.js) presentation generator.

Current version uses reveal.js 2.6.1

## Installation

Simply install the gem:

    gem install reveal.rb

## Usage

    # create a new presentation
    reveal create my-presentation
    cd my-presentation

    # add some slides
    reveal add-slide slide1 slide2 slide3

    # after editing your slides, generate the reveal.js presentation
    reveal generate

That's it! Now open `output/index.html` to watch your presentation.

## Configuration

Currently, reveal.rb doesn't support any configuration options yet. But
there are some indirect ways to change some configuration parameters.

### Slides order

`reveal generate` command adds the slides in alphabetical order. That
means, if you call `reveal add-slide slide2 slide1` and then `reveal
generate`, it will add `slide1` before `slide2`.

### reveal.js configurations

`reveal create` command adds a `template.html` file to your
presentation, with reveal.js default configurations. If you want to
change some configuration, just edit this file before running `reveal
generate`.
