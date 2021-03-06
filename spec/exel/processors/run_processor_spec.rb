# frozen_string_literal: true

describe EXEL::Processors::RunProcessor do
  subject { EXEL::Processors::RunProcessor.new(context) }

  let(:context) { EXEL::Context.new(job: :test_job) }

  describe '#process' do
    it 'runs the job named in context[:job] with the current context' do
      expect(EXEL::Job).to receive(:run).with(:test_job, context)
      subject.process
    end
  end
end
