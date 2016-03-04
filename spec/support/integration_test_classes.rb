Person = Struct.new(:name, :email)

class EmailService
  def send_to(email)
    raise 'Invalid email' unless email =~ /\w+@\w+/
  end
end

class RecordLoader
  def initialize(context)
    @context = context
  end

  def process(_block)
    @context[:people] = []

    CSV.foreach(@context[:resource].path) do |row|
      @context[:people] << Person.new(*row)
    end
  end
end

class EmailProcessor
  def initialize(context)
    @context = context
    @people = context[:people]
    @email_service = context[:email_service]
  end

  def process(_block)
    @people.each { |person| @email_service.send_to(person.email) }
  end
end
