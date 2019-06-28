require 'logger'

module Reveal
  module Cli
    extend self

    def process(args)
      command_name = args.first.gsub('-', '_')
      command_args = args[1..-1]
      cmd = Reveal::Command.new(logger)
      supported_cmds = cmd.methods - cmd.class.methods
      unless supported_cmds.include?(command_name.to_sym)
        puts "Command '#{command_name}' not supported.\nSupported commands: #{supported_cmds.join(", ")}"
        exit 1
      end

      send(command_name, command_args)
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
