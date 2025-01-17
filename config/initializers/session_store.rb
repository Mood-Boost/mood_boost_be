# config/initializers/session_store.rb
Rails.application.config.session_store :cookie_store, key: '_mood_boost_session', secure: Rails.env.production?
