# frozen_string_literal: true

describe EXEL::Middleware do
  class IORecorder
    def initialize(input, output)
      @input = input
      @output = output
    end

    def call(_processor, context, args)
      @input << args[:input]
      yield
      @output << context[:output]
    end
  end

  class RescueErrors
    def call(_processor, _context, _args)
      yield
    rescue
      nil
    end
  end

  class AddProcessor
    def initialize(context)
      @context = context
    end

    def process(_)
      @context[:output] = @context[:input] + 1
      raise 'rescue me'
    end
  end

  before :all do # rubocop:disable RSpec/BeforeAfterAll
    EXEL::Job.define :middleware_test_job do
      process with: AddProcessor, input: 1
    end
  end

  let(:input) { [] }
  let(:output) { [] }

  before do
    EXEL.configure do |config|
      config.middleware.add(IORecorder, input, output)
      config.middleware.add(RescueErrors)
    end
  end

  after do
    EXEL.configure do |config|
      config.middleware.remove(IORecorder)
      config.middleware.remove(RescueErrors)
    end
  end

  it 'can configure custom middleware' do
    expect(EXEL.configuration.middleware.entries.map(&:klass)).to eq([IORecorder, RescueErrors])
  end

  it 'invokes the middleware around the processor' do
    EXEL::Job.run(:middleware_test_job)
    expect(input).to eq([1])
    expect(output).to eq([2])
  end
end
