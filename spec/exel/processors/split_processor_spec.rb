# frozen_string_literal: true

describe EXEL::Processors::SplitProcessor do
  subject(:splitter) { EXEL::Processors::SplitProcessor.new(context) }

  let(:chunk_file) { instance_double(File) }
  let(:file) { create_file(1) }
  let(:context) { EXEL::Context.new(resource: file) }
  let(:callback) { instance_double(EXEL::SequenceNode) }

  before do
    allow_any_instance_of(StringIO).to receive(:path).and_return('/text.txt')
    allow(File).to receive(:delete)
  end

  describe '#process' do
    let(:file) { create_file(3) }

    it 'processes file with 3 lines line by line' do
      allow(CSV).to receive(:foreach).and_yield('line0').and_yield('line1').and_yield('line2')

      3.times do |i|
        expect(splitter).to receive(:process_line).with("line#{i}", callback)
      end
      expect(splitter).to receive(:process_line).with(:eof, callback)

      expect(File).to receive(:delete).with(file.path)
      expect(file).to receive(:close)

      splitter.process(callback)
    end

    it 'aborts parsing the csv file if it is malformed' do
      allow(CSV).to receive(:foreach).and_raise(CSV::MalformedCSVError.new('message', '1'))
      expect(splitter).to receive(:process_line).with(:eof, callback)

      splitter.process(callback)
    end

    it 'does not delete the resource file if :delete_resource is set to false in the context' do
      allow(CSV).to receive(:foreach).and_yield(:eof)
      expect(File).not_to receive(:delete).with(file.path)

      context[:delete_resource] = false
      splitter.process(callback)
    end

    it 'stops splitting at :max_chunks if it is set in the context' do
      allow(CSV).to receive(:foreach).and_yield(['line0']).and_yield(['line1']).and_yield(['line2'])

      chunk_file = create_file(0)

      allow(Tempfile).to receive(:new).and_return(chunk_file)
      expect(callback).to receive(:run).once
      allow_any_instance_of(StringIO).to receive(:path).and_return('test path')

      expect(File).to receive(:delete).with(file.path)

      context[:chunk_size] = 2
      context[:max_chunks] = 1
      splitter.process(callback)

      expect(chunk_file.read).to eq("line0\nline1\n")
    end

    it 'ensures that the source file gets closed and deleted' do
      allow(CSV).to receive(:foreach).and_raise(Interrupt)

      expect(File).to receive(:delete).with(file.path)
      expect(file).to receive(:close)

      begin
        splitter.process(callback)
      rescue Interrupt
        nil
      end
    end
  end

  describe '#process_line' do
    [
        {input: 1, chunks: %W(0\n)},
        {input: 3, chunks: %W(0\n1\n 2\n)},
        {input: 4, chunks: %W(0\n1\n 2\n3\n)},
    ].each do |data|
      it "produces #{data[:chunks].size} chunks with #{data[:input]} input lines" do
        context[:chunk_size] = 2

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
    it 'creates a file with the contents of the given string' do
      file = splitter.generate_chunk('abc')
      content = file.read
      expect(content).to eq('abc')
    end

    it 'creates a file with a unique name' do
      3.times do |i|
        file = splitter.generate_chunk('content')
        expect(file.path).to include("text_#{i + 1}_")
      end
    end
  end

  def create_file(lines)
    content = Array.new(lines) { |i| CSV.generate_line(["line#{i}"]) }.join
    StringIO.new(content)
  end
end
