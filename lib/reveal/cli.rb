require 'logger'

module Reveal
  module Cli
    extend self

    def process(args)
      command_name = args.first.gsub('-', '_')
      command_args = args[1..-1]
      Reveal::Command.new(logger).send(command_name, command_args)
    rescue Exception => e
      puts e.message
      exit 1
    end

    private

    def logger
      @logger ||= begin
        logger = ::Logger.new(STDOUT)
        logger.formatter = proc do |_, _, _, msg|
          "#{msg}\n"
        end

        logger
      end
    end
  end
end
