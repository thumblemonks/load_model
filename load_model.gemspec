Gem::Specification.new do |s|
  s.name     = "load_model"
  s.version  = "0.1.0"
  s.date     = "2009-01-03"
  s.summary  = "Rails Controller plugin that provides easy and useful macros for tying models and requests together"
  s.email    = %w[gus@gusg.us gabriel.gironda@gmail.com]
  s.homepage = "http://github.com/thumblemonks/load_model"
  s.description = "Rails Controller plugin that provides easy and useful macros for tying models and requests together"
  s.authors  = %w[Justin\ Knowlden Gabriel\ Gironda]

  s.rubyforge_project = %q{load_model}

  s.has_rdoc = true
  s.rdoc_options = ["--line-numbers", "--inline-source", "--title", "Load Model", "--main", "README.markdown"]
  s.extra_rdoc_files = ["HISTORY.markdown", "README.markdown"]
  
  s.required_rubygems_version = Gem::Requirement.new(">= 1.2") if s.respond_to?(:required_rubygems_version=)
  s.rubygems_version = "1.3.1"
  s.require_paths = ["lib"]

  # run git ls-files to get an updated list
  s.files = %w[
    HISTORY.markdown
    MIT-LICENSE
    README.markdown
    Rakefile
    lib/load_model.rb
    load_model.gemspec
  ]
  
  s.test_files = %w[
    rails/app/controllers/application.rb
    rails/config/boot.rb
    rails/config/database.yml
    rails/config/environment.rb
    rails/config/environments/test.rb
    rails/config/routes.rb
    rails/db/schema.rb
    rails/db/test.db
    rails/log/test.log
    test/functional/controller_helper.rb
    test/functional/keys_controller_test.rb
    test/functional/load_model_test.rb
    test/functional/require_model_controller_test.rb
    test/functional/restrict_options_controller_test.rb
    test/functional/string_key_load_model_test.rb
    test/functional/through_controller_test.rb
    test/test_helper.rb
  ]

  s.post_install_message = %q{Choosy prima donnas choose Thumble Monks}
end
