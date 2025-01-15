class Translation
  attr_reader :detected_source_language, :text

  def initialize(data)
    @detected_source_language = data[:source_language]
    @text = data[:text]
  end
end