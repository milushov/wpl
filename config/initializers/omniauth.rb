OmniAuth.config.logger = Rails.logger

Rails.application.config.middleware.use OmniAuth::Builder do
  APP_ID = ENV['USER'] ? 2999165 : 1111000 # development and production app id
  APP_SECRET = '1111000key'
  provider :vkontakte, APP_ID, APP_SECRET, :scope => 'notify,friends,audio', :display => 'page'
end
