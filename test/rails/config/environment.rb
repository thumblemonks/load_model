# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '2.3.2' unless defined? RAILS_GEM_VERSION

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|
  config.gem 'thoughtbot-shoulda', :lib => 'shoulda/rails', :source => 'http://gems.github.com'

  config.action_controller.session = {
    :session_key => '_load_model_session',
    :secret      => '9908cd9908cd9908cd9908cd9908cd9908cd9908cd9908cd9908cd9908cd9908cd9908cd9908cd'
  }
end

require 'ruby-debug'