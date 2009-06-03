Gem::Specification.new do |s|
  s.name     = "load_model"
  s.version  = "0.2.2"
  s.date     = "2009-06-03"
  s.summary  = "Rails Controller plugin that provides easy and useful macros for tying models and requests together"
  s.email    = %w[gus@gusg.us gabriel.gironda@gmail.com]
  s.homepage = "http://github.com/thumblemonks/load_model"
  s.description = "Rails Controller plugin that provides easy and useful macros for tying models and requests together"
  s.authors  = %w[Justin\ Knowlden Gabriel\ Gironda Dan\ Hodos]

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
    lib/thumblemonks/model_loader.rb
    load_model.gemspec
  ]
  
  s.test_files = %w[
    test/functional/basic_controller_test.rb
    test/functional/from_controller_test.rb
    test/functional/keys_controller_test.rb
    test/functional/require_model_controller_test.rb
    test/functional/restrict_options_controller_test.rb
    test/functional/string_key_controller_test.rb
    test/functional/through_controller_test.rb
    test/rails/app/controllers/application.rb
    test/rails/config/boot.rb
    test/rails/config/database.yml
    test/rails/config/environment.rb
    test/rails/config/environments/test.rb
    test/rails/config/routes.rb
    test/rails/db/schema.rb
    test/test_helper.rb
  ]

  s.post_install_message = %q{Choosy prima donnas choose Thumble Monks}
end
