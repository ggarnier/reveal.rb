require 'fileutils'

module Reveal
  SOURCE_DIR = "source"
  OUTPUT_DIR = "output"
  TEMPLATE_FILENAME = "template.html"
  SLIDES_TAG = "<slides>"

  module Cli
    extend self

    def process args
      self.send(args.first.gsub("-", "_"), args[1..-1])
    end

    def create args
      name = args.first

      if Dir.exists?(name)
        puts "#{name} already exists."
        exit 1
      end

      FileUtils.mkdir_p(File.join(name, SOURCE_DIR))
      FileUtils.mkdir_p(File.join(name, OUTPUT_DIR))
      FileUtils.cp(File.join(templates_path, TEMPLATE_FILENAME), name)
      FileUtils.cp_r(File.join(templates_path, "revealjs", "."), File.join(name, OUTPUT_DIR))

      puts "#{name} presentation created."
    end

    def add_slide args
      check_if_presentation_exists

      args.each do |slide_name|
        filepath = File.join(SOURCE_DIR, "#{slide_name}.md")
        FileUtils.touch(filepath)
        puts "#{filepath} created."
      end
    end

    def generate args
      check_if_presentation_exists

      source_content = ""

      Dir.glob(File.join(SOURCE_DIR, "*.md")).each do |filename|
        source_content << <<-SLIDE
      <section data-markdown>
      #{File.read(filename)}
      </section>

      SLIDE
      end

      template = File.read(TEMPLATE_FILENAME)
      compiled_filename = File.join(OUTPUT_DIR, "index.html")
      File.open(compiled_filename, "w") do |file|
        file.write(template.gsub(SLIDES_TAG, source_content))
      end

      puts "#{compiled_filename} presentation generated."
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
  end
end
