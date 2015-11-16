module EXEL
  describe Instruction do
    subject(:instruction) { EXEL::Instruction.new('ins_name', processor_class, args) }
    let(:processor_class) { double(:processor_class, new: processor_instance) }
    let(:processor_instance) { double(:processor_instance, process: nil) }
    let(:args) { {arg1: 'arg_value1', arg2: {}} }
    let(:context) { {context_key: 'context_value'} }

    describe '#run' do
      it 'should call process on an instance of the processor class' do
        expect(processor_class).to receive(:new).and_return(processor_instance)
        expect(processor_instance).to receive(:process)

        instruction.execute(context)
      end

      it 'should not pass a copy of the context' do
        allow(processor_class).to receive(:new) do |context_arg|
          expect(context_arg).to be(context)
          processor_instance
        end

        instruction.execute(context)
      end

      it 'should add args to the context' do
        instruction.execute(context)
        expect(context.keys).to include(*args.keys)
      end

      context 'with args' do
        it 'should pass the args to the processor' do
          expect(processor_class).to receive(:new).with(hash_including(args))
          instruction.execute(context)
        end
      end

      context 'without args' do
        let(:args) { nil }

        it 'should just pass the context to the processor' do
          expect(processor_class).to receive(:new).with(context)
          instruction.execute(context)
        end
      end

      context 'with a subtree' do
        let(:subtree) { double(:subtree) }
        subject(:instruction) { EXEL::Instruction.new('ins_name', processor_class, args, subtree) }

        it 'should pass the subtree to the processor' do
          expect(processor_instance).to receive(:process).with(subtree)
          instruction.execute(context)
        end
      end
    end
  end
end