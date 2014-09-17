require 'minitest/spec'
require 'minitest/autorun'

require_relative '../../../lib/reveal'

describe Reveal::Cli do
  let :subject do
    Reveal::Cli
  end

  let :logger do
    Minitest::Mock.new
  end

  describe '.process' do
    it 'delegates to Reveal::Command method call with arguments' do
      command = Minitest::Mock.new
      command.expect(:send, nil, ['method_name', ['arg1', 'arg2']])

      Reveal::Command.stub(:new, command) do
        subject.process(['method-name', 'arg1', 'arg2'])
        command.verify
      end
    end
  end
end
