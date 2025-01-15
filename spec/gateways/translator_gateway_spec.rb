require 'rails_helper'

RSpec.describe TranslationGateway do
  describe "API call:" do
    context "class methods:" do
      it "gets translation" do
        text_param = "Why did Elon Musk divorce his wife? He heard marriage is a union."
        target_language_param = 
        translation = TranslationGateway.get_translation

      end
    end
  end
end