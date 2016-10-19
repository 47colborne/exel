# frozen_string_literal: true
module EXEL
  describe LoggingHelper do
    class HelperClass
      include LoggingHelper
    end

    let(:helper) { HelperClass.new }

    describe '#logger' do
      it 'returns EXEL.logger' do
        expect(helper.logger).to eq(EXEL.logger)
      end
    end

    %i(debug info warn error fatal).each do |level|
      describe "#log_#{level}" do
        it "logs a #{level} message" do
          expect(EXEL.logger).to receive(level).with('test')
          helper.send("log_#{level}", 'test')
        end
      end
    end
  end
end
