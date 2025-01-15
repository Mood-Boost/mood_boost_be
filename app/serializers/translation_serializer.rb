class ActivitySerializer
  include JSONAPI::Serializer

  attributes :detected_source_language, :text
end