# frozen_string_literal: true

class Person < Struct.new(:name, :email)
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
  include EXEL::Events

  def initialize(context)
    @context = context
    @people = context[:people]
    @email_service = context[:email_service]
  end

  def process(_block)
    @people.each do |person|
      @email_service.send_to(person.email)
      trigger :email_sent, email: person.email
    end
  end
end

class EmailService
  def send_to(_email)
  end
end

class EmailListener
  def self.email_sent(_context, _data)
  end
end
