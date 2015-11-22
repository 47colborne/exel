module EXEL
  describe ExecutionWorker do
    it 'should run the given block with the deserialized context' do
      dsl_block = instance_double(SequenceNode)
      context = Context.new(test1: 'foo', test2: 2, _block: dsl_block)
      context_uri = 'test uri'

      expect(Context).to receive(:deserialize).with(context_uri).and_return(context)
      expect(dsl_block).to receive(:start).with(context)
      ExecutionWorker.new.perform(context_uri)
    end
  end
end