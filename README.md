# reveal.rb

[![Code Climate](https://codeclimate.com/github/ggarnier/reveal.rb/badges/gpa.svg)](https://codeclimate.com/github/ggarnier/reveal.rb)
[![Build Status](https://travis-ci.org/ggarnier/reveal.rb.svg)](https://travis-ci.org/ggarnier/reveal.rb)
[![Dependency Status](https://gemnasium.com/ggarnier/reveal.rb.png)](https://gemnasium.com/ggarnier/reveal.rb)
[![Analytics](https://ga-beacon.appspot.com/UA-25495907-3/github/reveal.rb)](https://github.com/igrigorik/ga-beacon)

[reveal.js](https://github.com/hakimel/reveal.js) presentation generator.

Current version uses reveal.js 3.6.0

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

All currently supported configurations are made through `reveal.yml` file.

### Slides order

There are two ways to order your slides:

* **Manual order**: set `order` parameter to `manual` and list your slide names in `slides` parameter. This is the default configuration, and it's automatically done for you with `reveal add-slide` command. Any slide file created inside `source` directory but not included in the configuration file will be ignored. Example:

<pre>
    ---
    order: manual
    slides:
    - slide1
    - slide2
    - slide3
</pre>

* **Alphabetical order**: if you omit `order` parameter (or set it to anything other than `manual`), `reveal generate` command will add all slide files inside `source`, in alphabetical order.

### reveal.js configurations

`reveal create` command adds a `template.html` file to your
presentation, with reveal.js default configurations. If you want to
change some configuration, just edit this file before running `reveal
generate`.
