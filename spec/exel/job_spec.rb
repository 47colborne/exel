# frozen_string_literal: true

describe EXEL::Job do
  describe '.define' do
    let(:ast) { instance_double(EXEL::SequenceNode, run: nil, start: nil) }
    let(:block) { proc {} }

    after { EXEL::Job.registry.clear }

    it 'registers job definitions' do
      EXEL::Job.define :test_job, &block
      expect(EXEL::Job.registry[:test_job]).to eq(block)
    end

    it 'raises an exception if a job name is already in use' do
      EXEL::Job.define :test_job, &block
      expect { EXEL::Job.define :test_job, &block }.to raise_error 'Job :test_job is already defined'
    end
  end

  describe '.run' do
    let(:ast) { instance_double(EXEL::SequenceNode, run: nil, start: nil) }
    let(:context) { instance_double(EXEL::Context) }

    context 'with a string of DSL code' do
      it 'parses the code' do
        dsl_code = 'code'
        expect(EXEL::Job::Parser).to receive(:parse).with(dsl_code).and_return(ast)
        EXEL::Job.run(dsl_code, context)
      end

      it 'runs the AST returned by the parser' do
        allow(EXEL::Job::Parser).to receive(:parse).and_return(ast)
        expect(ast).to receive(:start).with(context)
        EXEL::Job.run('code', context)
      end

      it 'returns the context' do
        allow(EXEL::Job::Parser).to receive(:parse).and_return(ast)
        result = EXEL::Job.run('code', context)
        expect(result).to be(context)
      end
    end

    context 'with a job name' do
      context 'of a defined job' do
        let(:block) { proc {} }

        before do
          allow(EXEL::Job).to receive(:registry).and_return(test_job: block)
        end

        it 'runs the job' do
          expect(EXEL::Job::Parser).to receive(:parse).with(block).and_return(ast)
          expect(ast).to receive(:start).with(context)
          EXEL::Job.run(:test_job, context)
        end

        it 'returns the context' do
          result = EXEL::Job.run(:test_job, context)
          expect(result).to be(context)
        end
      end

      context 'of a undefined job' do
        it 'returns nil' do
          expect { EXEL::Job.run(:test_job, context) }.to raise_error('Job "test_job" not found')
        end
      end
    end
  end

  describe 'mutation of arguments' do
    module EXEL
      module Processors
        class TestProcessor
          def initialize(context)
            context[:array] << context[:arg]
          end

          def process(_callback)
          end
        end
      end
    end

    it 'does not persist between runs' do
      EXEL::Job.define :test do
        process with: EXEL::Processors::TestProcessor, array: [], arg: context[:value]
      end

      context = EXEL::Context.new(value: 1)
      EXEL::Job.run(:test, context)
      expect(context[:array]).to eq([1])

      context = EXEL::Context.new(value: 2)
      EXEL::Job.run(:test, context)
      expect(context[:array]).to eq([2])
    end
  end

  describe EXEL::Job::Parser do
    let(:parser) { EXEL::Job::Parser.new }
    let(:ast) { instance_double(EXEL::SequenceNode, run: nil) }

    describe '#initialize' do
      it 'initializes a sequence node' do
        expect(parser.ast).to be_kind_of(EXEL::SequenceNode)
      end
    end

    describe '.parse' do
      let(:parser) { instance_double(EXEL::Job::Parser, ast: ast, instance_eval: nil) }

      before do
        allow(EXEL::Job::Parser).to receive(:new).and_return(parser)
      end

      context 'given DSL code as a proc' do
        it 'evals the code as a block' do
          dsl_proc = proc {}
          expect(parser).to receive(:instance_eval) do |*_args, &block|
            expect(block).to eq(dsl_proc)
          end

          EXEL::Job::Parser.parse(dsl_proc)
        end
      end

      context 'given DSL code as a string' do
        it 'evals the code as a string' do
          dsl_code = 'code'
          expect(parser).to receive(:instance_eval).with(dsl_code)

          EXEL::Job::Parser.parse(dsl_code)
        end
      end

      it 'returns the parsed AST' do
        expect(EXEL::Job::Parser.parse(proc {})).to eq(ast)
      end
    end

    describe '#process' do
      let(:block) { proc {} }
      let(:processor_class) { class_double(Class) }

      before { allow(EXEL::Job::Parser).to receive(:parse).and_return(ast) }

      context 'without a block' do
        it 'creates a process instruction' do
          expect(EXEL::Instruction).to receive(:new).with(processor_class, {arg1: 'arg1_value'}, subtree: nil)

          parser.process with: processor_class, arg1: 'arg1_value'
        end

        it 'appends an instruction node to the AST with no children' do
          expect(parser.ast).to receive(:add_child) do |node|
            expect(node).to be_a_kind_of(EXEL::InstructionNode)
            expect(node.children).to eq([])
          end

          parser.process with: processor_class
        end
      end

      context 'with a block' do
        it 'passes the parsed subtree to the instruction' do
          expect(EXEL::Job::Parser).to receive(:parse).with(block).and_return(ast)
          expect(EXEL::Instruction).to receive(:new).with(processor_class, {arg1: 'arg1_value'}, subtree: ast)

          parser.process with: processor_class, arg1: 'arg1_value', &block
        end

        it 'appends an instruction node to the AST with the parsed block as its subtree' do
          expect(parser.ast).to receive(:add_child) do |node|
            expect(node).to be_a_kind_of(EXEL::InstructionNode)
            expect(node.children).to eq([ast])
          end

          parser.process with: processor_class, &block
        end
      end
    end

    [
        {method: :async, processor: EXEL::Processors::AsyncProcessor},
        {method: :split, processor: EXEL::Processors::SplitProcessor},
        {method: :run, processor: EXEL::Processors::RunProcessor},
    ].each do |data|
      describe "##{data[:method]}" do
        before do
          allow(EXEL::Job::Parser).to receive(:parse).and_return(ast)
        end

        it "creates a #{data[:method]} instruction" do
          expect(EXEL::Instruction).to receive(:new).with(data[:processor], {arg1: 'arg1_value'}, subtree: ast)
          parser.send(data[:method], arg1: 'arg1_value') {}
        end

        it 'parses the block given' do
          block = -> {}
          expect(EXEL::Job::Parser).to receive(:parse).with(block).and_return(ast)

          parser.send(data[:method], &block)
        end

        it 'adds parsed subtree and instruction to the AST' do
          expect(parser.ast).to receive(:add_child) do |node|
            expect(node).to be_a_kind_of(EXEL::InstructionNode)
            expect(node.children).to eq([ast])
          end

          parser.send(data[:method]) {}
        end
      end
    end

    describe '#context' do
      it 'returns a DeferredContextValue' do
        expect(parser.context).to be_a_kind_of(EXEL::DeferredContextValue)
      end
    end

    describe '#listen' do
      let(:listener_class) { class_double(Class) }

      it 'creates a listen instruction' do
        expect(EXEL::ListenInstruction).to receive(:new).with(:event, listener_class)
        parser.listen for: :event, with: listener_class
      end

      it 'adds an InstructionNode containing the listen instruction' do
        parser.listen for: :event, with: listener_class
        node = parser.ast.children.first
        expect(node).to be_a_kind_of(EXEL::InstructionNode)
        expect(node.instruction).to be_a_kind_of(EXEL::ListenInstruction)
      end
    end
  end
end
