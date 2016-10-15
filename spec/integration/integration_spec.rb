# frozen_string_literal: true
describe EXEL do
  let(:context) { EXEL::Context.new(resource: csv_file, email_service: email_service, delete_resource: false) }
  let(:csv_file) { File.open(File.expand_path('../../fixtures/sample.csv', __FILE__)) }
  let(:email_service) { EmailService.new }

  before :all do
    EXEL::Job.define :processing_steps do
      process with: RecordLoader
      process with: EmailProcessor
    end

    EXEL::Job.define :integration_test_job do
      async do
        listen for: :email_sent, with: EmailListener

        split chunk_size: 10, csv_options: {headers: :first_line} do
          async { run job: :processing_steps }
        end
      end
    end
  end

  after do
    csv_file.close
  end

  def run_until_complete
    done = 0
    allow_any_instance_of(EmailService).to receive(:send_to) { done += 1 }

    yield

    # wait up to 2 seconds for calls to occur
    start_time = Time.now
    sleep 0.1 while done < 500 && Time.now - start_time < 2

    expect(done).to eq(500)
  end

  it 'runs a complete job' do
    run_until_complete { EXEL::Job.run(:integration_test_job, context) }
  end

  it 'calls a registered event listener' do
    allow(EmailListener).to receive(:email_sent)

    run_until_complete { EXEL::Job.run(:integration_test_job, context) }

    expect(EmailListener).to have_received(:email_sent).exactly(500).times
  end
end
