require 'fileutils'
require 'yaml'
require 'logger'

module Reveal
  SOURCE_DIR = 'source'
  OUTPUT_DIR = 'output'
  TEMPLATE_FILENAME = 'template.html'
  CONFIG_FILENAME = 'reveal.yml'
  SLIDES_TAG = '<slides>'
  MARKDOWN_EXTENSION = 'md'

  class Command
    def initialize(logger = ::Logger.new(STDOUT))
      @logger = logger
    end

    def create(args)
      name = Array(args).first

      if File.exist?(name)
        raise "ERROR: #{name} already exists."
      end

      FileUtils.mkdir_p(File.join(name, SOURCE_DIR))
      FileUtils.mkdir_p(File.join(name, OUTPUT_DIR))

      FileUtils.cp(File.join(templates_path, TEMPLATE_FILENAME), name)
      FileUtils.cp(File.join(templates_path, CONFIG_FILENAME), name)
      FileUtils.cp_r(File.join(templates_path, 'revealjs', '.'), File.join(name, OUTPUT_DIR))

      @logger.info("Presentation '#{name}' created.")
    end

    def add_slide(args)
      check_if_presentation_exists

      config['slides'] ||= []

      Array(args).each do |slide_name|
        filepath = File.join(SOURCE_DIR, slide_filename(slide_name))
        FileUtils.touch(filepath)
        config['slides'] << slide_name
        @logger.info("Slide '#{filepath}' created.")
      end

      write_config
    end

    def generate(_ = nil)
      check_if_presentation_exists

      source_content = ''

      ordered_slide_names.each do |filename|
        source_content << <<-SLIDE
      <section data-markdown>
        <script type="text/template">
          #{File.read(filename)}
        </script>
      </section>

        SLIDE
      end

      template = File.read(TEMPLATE_FILENAME)
      compiled_filename = File.join(OUTPUT_DIR, 'index.html')
      File.open(compiled_filename, 'w') do |file|
        file.write(template.gsub(SLIDES_TAG, source_content))
      end

      @logger.info("'#{compiled_filename}' presentation file generated.")
    end

    private

    def check_if_presentation_exists
      unless File.exist?(TEMPLATE_FILENAME) && File.exist?(CONFIG_FILENAME) && Dir.exist?(SOURCE_DIR) && Dir.exist?(OUTPUT_DIR)
        raise "ERROR: The current working directory does not seem to have a reveal.rb presentation.\nCreate one with 'reveal create <presentation name>'."
      end
    end

    def templates_path
      @templates_path ||= begin
        [
          File.join(File.dirname(File.expand_path(__FILE__)), 'templates'),
          File.join(File.dirname(File.expand_path($0)), '..', 'lib', 'reveal', 'templates'),
          File.join(Gem.dir, 'gems', "reveal.rb-#{Reveal::VERSION}", 'lib', 'reveal', 'templates')
        ].select { |item| File.readable?(item) }.first
      end
    end

    def ordered_slide_names
      if config && config['order'] == 'manual' && config['slides']
        config['slides'].
          map { |slide_name| File.join(SOURCE_DIR, "#{slide_name}.#{MARKDOWN_EXTENSION}") }.
          select { |filepath| File.readable?(filepath) }
      else
        Dir.glob(File.join(SOURCE_DIR, "*.#{MARKDOWN_EXTENSION}"))
      end
    end

    def config
      @config ||= YAML.load(File.read(CONFIG_FILENAME))
    end

    def write_config
      File.write(CONFIG_FILENAME, config.to_yaml)
    end

    def slide_filename(slide_name)
      slide_name =~ /\.#{MARKDOWN_EXTENSION}$/ ? slide_name : "#{slide_name}.#{MARKDOWN_EXTENSION}"
    end
  end
end
