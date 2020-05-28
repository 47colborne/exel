class RemoteValue
  attr_reader :uri

  def initialize(uri)
    @uri = uri
  end

  def ==(other)
    other.class == self.class && other.uri == @uri
  end
end
