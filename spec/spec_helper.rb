Dir[File.expand_path('../../lib/**/*.rb', __FILE__)].each { |f| require f }

EXEL.logger = nil

EXEL.configure do |config|
  config.aws = OpenStruct.new
end