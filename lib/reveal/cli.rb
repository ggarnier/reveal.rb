require 'fileutils'
require 'yaml'

module Reveal
  SOURCE_DIR = "source"
  OUTPUT_DIR = "output"
  TEMPLATE_FILENAME = "template.html"
  CONFIG_FILENAME = "reveal.yml"
  SLIDES_TAG = "<slides>"

  module Cli
    extend self

    def process args
      self.send(args.first.gsub("-", "_"), args[1..-1])
    end

    def create args
      name = args.first

      if File.exists?(name)
        puts "#{name} already exists."
        exit 1
      end

      FileUtils.mkdir_p(File.join(name, SOURCE_DIR))
      FileUtils.mkdir_p(File.join(name, OUTPUT_DIR))
      FileUtils.cp(File.join(templates_path, TEMPLATE_FILENAME), name)
      FileUtils.cp(File.join(templates_path, CONFIG_FILENAME), name)
      FileUtils.cp_r(File.join(templates_path, "revealjs", "."), File.join(name, OUTPUT_DIR))

      puts "Presentation '#{name}' created."
    end

    def add_slide args
      check_if_presentation_exists

      config["slides"] ||= []

      args.each do |slide_name|
        filepath = File.join(SOURCE_DIR, "#{slide_name}.md")
        FileUtils.touch(filepath)
        config["slides"] << slide_name
        puts "Slide '#{filepath}' created."
      end

      write_config
    end

    def generate args
      check_if_presentation_exists

      source_content = ""

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
      compiled_filename = File.join(OUTPUT_DIR, "index.html")
      File.open(compiled_filename, "w") do |file|
        file.write(template.gsub(SLIDES_TAG, source_content))
      end

      puts "#{compiled_filename} presentation file generated."
    end

    private
    def check_if_presentation_exists
      unless File.exists?(TEMPLATE_FILENAME) && Dir.exists?(SOURCE_DIR) && Dir.exists?(OUTPUT_DIR)
        puts "Error: The current working directory does not seem to have a reveal.rb presentation."
        puts "Create one with 'reveal create <presentation name>'."
        exit 1
      end
    end

    def templates_path
      @templates_path ||= begin
        [
          File.join(File.dirname(File.expand_path($0)), "..", "lib", "reveal", "templates"),
          File.join(Gem.dir, "gems", "reveal.rb-#{Reveal::VERSION}", "lib", "reveal", "templates")
        ].select { |item| File.readable?(item) }.first
      end
    end

    def ordered_slide_names
      if config && config["order"] == "manual" && config["slides"]
        config["slides"].
          map { |slide_name| File.join(SOURCE_DIR, "#{slide_name}.md") }.
          select { |filepath| File.readable?(filepath) }
      else
        Dir.glob(File.join(SOURCE_DIR, "*.md"))
      end
    end

    def config
      @config ||= YAML.load(File.read(CONFIG_FILENAME))
    end

    def write_config
      File.write(CONFIG_FILENAME, config.to_yaml)
    end
  end
end
