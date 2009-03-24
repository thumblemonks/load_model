def require_local_lib(pattern)
  Dir.glob(File.join(File.dirname(__FILE__), pattern)).each {|f| require f }
end

ENV["RAILS_ENV"] = "test"
ENV["RAILS_ROOT"] = File.expand_path(File.join(File.dirname(__FILE__), '..', 'test', 'rails'))
require File.expand_path(File.join(ENV["RAILS_ROOT"], 'config', 'environment'))
require File.expand_path(File.join(File.dirname(__FILE__), '..', 'lib', 'load_model'))
require 'test_help'
load(File.join(ENV["RAILS_ROOT"], "db", "schema.rb"))

require_local_lib('models/*.rb')
require_local_lib('controllers/*.rb')