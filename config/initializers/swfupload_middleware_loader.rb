if defined?(::Rails.configuration) && ::Rails.configuration.respond_to?(:middleware)
  ::Rails.configuration.middleware.insert_after 'ActionDispatch::Cookies', FlashSessionCookieMiddleware, ::Rails.configuration.session_options[:key]
end
