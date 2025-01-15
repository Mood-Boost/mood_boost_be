class Api::V1::TranslationsController < ApplicationController
  def create
    begin
      translation = TranslationGateway.get_translation
      render json: TranslationSerializer.new(translation)
    rescue => e
      error_message = ErrorMessage.new("Could not translate", :bad_request)
      render json: ErrorSerializer.format_error(error_message), :bad_request :
  end
end