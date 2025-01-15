class TranslationGateway 
    def self.get_translation(text, target_language)
      deepl_api_key = Rails.application.credentials.dig(:deepl, :api_key)
      response = Faraday.post("https://api-free.deepl.com/v2/translate") do |request|
        request.headers["Authorization"] = "DeepL-Auth-Key #{api_key}"
        request.params["text"] = text
        request.params["target_lang"] = target_language
        request.options.ssl = { verify: true }
      end

      if response.success?
        JSON.parse(response.body)['translations'].first['text']
      else
        raise "Failed to fetch translation: #{response.status} #{response.body}"
      end
    end
  end
end