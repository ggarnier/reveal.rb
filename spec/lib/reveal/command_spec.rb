require 'minitest/spec'
require 'minitest/autorun'

require 'tmpdir'
require_relative '../../../lib/reveal'

describe Reveal::Command do
  let :subject do
    Reveal::Command.new(logger)
  end

  let :logger do
    Minitest::Mock.new
  end

  let :root_path do
    Dir.mktmpdir
  end

  before do
    FileUtils.mkdir("#{root_path}/reveal")
    FileUtils.mkdir_p("#{root_path}/lib/reveal/templates")
    FileUtils.cd("#{root_path}/reveal")
  end

  after do
    FileUtils.rm_rf(root_path)
  end

  describe '#create' do
    describe "when there's already a directory with the presentation name" do
      before do
        FileUtils.mkdir('my_presentation')
      end

      it 'raises an exception' do
        -> { subject.create(['my_presentation']) }.must_raise RuntimeError
      end
    end

    describe "when there isn't a directory with the presentation name" do
      it 'creates source and output dir' do
        logger.expect(:info, nil, [String])

        subject.create(['my_presentation'])

        Dir.exist?('my_presentation/source').must_equal true
        Dir.exist?('my_presentation/output').must_equal true
      end

      it 'logs a success message' do
        logger.expect(:info, nil, ["Presentation 'my_presentation' created."])

        subject.create(['my_presentation'])

        logger.verify
      end
    end
  end

  describe '#add_slide' do
    describe 'when the presentation exists' do
      before do
        FileUtils.touch('template.html')
        File.write('reveal.yml', {}.to_yaml)
        FileUtils.mkdir('source')
        FileUtils.mkdir('output')
      end

      it 'creates a new slide file' do
        logger.expect(:info, nil, [String])
        subject.add_slide(['slide1'])

        File.exist?('source/slide1.md').must_equal true
      end

      it 'writes the updated configuration' do
        logger.expect(:info, nil, [String])
        subject.add_slide(['slide1'])

        config = YAML.load(File.read('reveal.yml'))
        config['slides'].must_equal ['slide1']
      end

      it 'logs a success message' do
        logger.expect(:info, nil, ["Slide 'source/slide1.md' created."])

        subject.add_slide(['slide1'])

        logger.verify
      end

      describe 'and slide name already includes ".md" extension' do
        it "doesn't add the extension to the file name" do
          logger.expect(:info, nil, [String])
          subject.add_slide(['new_slide.md'])

          File.exist?('source/new_slide.md.md').must_equal false
          File.exist?('source/new_slide.md').must_equal true
        end
      end
    end

    describe "when the presentation doesn't exist" do
      it 'raises an exception' do
        -> { subject.add_slide(['slide1']) }.must_raise RuntimeError
      end
    end
  end

  describe '#generate' do
    describe 'when the presentation exists' do
      before do
        FileUtils.touch('template.html')
        File.write('reveal.yml', {}.to_yaml)
        FileUtils.mkdir('source')
        FileUtils.mkdir('output')
        File.write('template.html', 'Presentation: <slides>')
        File.write('source/slide1.md', 'slide 1 content')
        File.write('source/slide2.md', 'slide 2 content')
      end

      describe 'and slides are automatically ordered' do
        it 'Updates the generated presentation with automatic slide ordering' do
          logger.expect(:info, nil, [String])
          subject.generate

          output = File.read('output/index.html')
          output.must_match /^Presentation: .*slide 1 content.*slide 2 content/m
        end
      end

      describe 'and slides are manually ordered' do
        before do
          File.write('reveal.yml', { 'order' => 'manual', 'slides' => ['slide2', 'slide1'] }.to_yaml)
          logger.expect(:info, nil, [String])
        end

        it 'Updates the generated presentation respecting the ordering' do
          subject.generate

          output = File.read('output/index.html')
          output.must_match /^Presentation: .*slide 2 content.*slide 1 content/m
        end

        describe 'and some slides are missing' do
          before do
            File.write('reveal.yml', { 'order' => 'manual', 'slides' => ['slide2', 'slide1', 'slide3'] }.to_yaml)
          end

          it 'ignores missing slides' do
            subject.generate

            output = File.read('output/index.html')
            output.must_match /^Presentation: .*slide 2 content.*slide 1 content/m
          end
        end
      end

      it 'logs a success message' do
        logger.expect(:info, nil, ["'output/index.html' presentation file generated."])

        subject.generate

        logger.verify
      end
    end

    describe "when the presentation doesn't exist" do
      it 'raises an exception' do
        -> { subject.generate(nil) }.must_raise RuntimeError
      end
    end
  end
end
