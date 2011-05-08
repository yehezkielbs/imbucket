module ImagesHelper
  def images_path_with_session_information
    session_key = Rails.application.config.session_options[:key]
    images_path(session_key => cookies[session_key], request_forgery_protection_token => form_authenticity_token)
  end
end
