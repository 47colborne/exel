  module EXEL
    module Processors
      describe SplitProcessor do
        let(:chunk_file) { instance_double(File) }
        let(:file) { create_file(1) }
        let(:context) { Context.new(resource: file) }
        let(:callback) { instance_double(SequenceNode) }
        subject(:splitter) { SplitProcessor.new(context) }

        before do
          allow_any_instance_of(StringIO).to receive(:path).and_return('/text.txt')
          allow(File).to receive(:delete)
        end

        describe '#process' do
          let(:file) { create_file(3) }

          it 'should process file with 3 lines line by line' do
            allow(CSV).to receive(:foreach).and_yield("line0").and_yield("line1").and_yield("line2")

            3.times do |i|
              expect(splitter).to receive(:process_line).with("line#{i}", callback)
            end
            expect(splitter).to receive(:process_line).with(:eof, callback)

            expect(File).to receive(:delete).with(file.path)

            splitter.process(callback)
          end

          it 'should abort parsing the csv file if it is malformed' do
            allow(CSV).to receive(:foreach).and_raise(CSV::MalformedCSVError)
            expect(splitter).to receive(:process_line).with(:eof, callback)

            splitter.process(callback)
          end
        end

        describe '#process_line' do
          [
              {input: 1, chunks: %W(0\n)},
              {input: 3, chunks: %W(0\n1\n 2\n)},
              {input: 4, chunks: %W(0\n1\n 2\n3\n)}
          ].each do |data|
            it "should produce #{data[:chunks].size} chunks with #{data[:input]} input lines" do
              splitter.chunk_size = 2

              data[:chunks].each do |chunk|
                expect(splitter).to receive(:generate_chunk).with(chunk).and_return(chunk_file)
                expect(callback).to receive(:run).with(context) do
                  expect(context[:resource]).to eq(chunk_file)
                end
              end

              data[:input].times { |i| splitter.process_line([i.to_s], callback) }
              splitter.process_line(:eof, callback)
            end
          end
        end

        describe '#generate_chunk' do
          it 'should create a file with the contents of the given string' do
            file = splitter.generate_chunk('abc')
            content = file.read
            expect(content).to eq('abc')
          end

          it 'should create a file with a unique name' do
            3.times do |i|
              index = i + 1
              file = splitter.generate_chunk("#{index}")
              file_name = splitter.get_filename(file)
              expect(file_name).to include("text_#{index}_")
            end
          end
        end

        def create_file(lines)
          content = ''

          lines.times do |i|
            line = CSV.generate_line(["line#{i}"])
            content << line
          end

          StringIO.new content
        end
      end
    end
  end
