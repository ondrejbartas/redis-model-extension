# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run 'rake gemspec'
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "redis-model-extension"
  s.version = "0.1.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Ondrej Bartas"]
  s.date = "2012-02-26"
  s.description = "It provides functions as find, find_by_alias, get, exists?, validate, save etc."
  s.email = "ondrej@bartas.cz"
  s.extra_rdoc_files = [
    "LICENSE.txt",
    "README.markdown"
  ]
  s.files = [
    ".document",
    "Gemfile",
    "LICENSE.txt",
    "README.markdown",
    "Rakefile",
    "VERSION",
    "config/redis_config.yml.example",
    "config/redis_setup.conf",
    "lib/database.rb",
    "lib/redis-model-extension.rb",
    "lib/string_to_bool.rb",
    "test/helper.rb",
    "test/test_redis-model-extension.rb"
  ]
  s.homepage = "http://github.com/ondrejbartas/redis-model-extension"
  s.licenses = ["MIT"]
  s.require_paths = ["lib"]
  s.rubygems_version = "1.8.10"
  s.summary = "Redis model is basic implementation of creating, finding, updating and deleting model which store data in Redis."

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<redis>, [">= 0"])
      s.add_runtime_dependency(%q<i18n>, ["~> 0.6.0"])
      s.add_runtime_dependency(%q<activesupport>, ["~> 3.1.0"])
      s.add_runtime_dependency(%q<rake>, [">= 0"])
      s.add_runtime_dependency(%q<rack>, ["~> 1.3.0"])
      s.add_development_dependency(%q<shoulda>, [">= 0"])
      s.add_development_dependency(%q<shoulda-context>, [">= 0"])
      s.add_development_dependency(%q<rdoc>, ["~> 3.12"])
      s.add_development_dependency(%q<bundler>, ["~> 1.0.0"])
      s.add_development_dependency(%q<jeweler>, ["~> 1.8.3"])
      s.add_development_dependency(%q<turn>, ["~> 0.8.2"])
      s.add_development_dependency(%q<minitest>, [">= 0"])
      s.add_development_dependency(%q<ansi>, ["~> 1.2.5"])
    else
      s.add_dependency(%q<redis>, [">= 0"])
      s.add_dependency(%q<i18n>, ["~> 0.6.0"])
      s.add_dependency(%q<activesupport>, ["~> 3.1.0"])
      s.add_dependency(%q<rake>, [">= 0"])
      s.add_dependency(%q<rack>, ["~> 1.3.0"])
      s.add_dependency(%q<shoulda>, [">= 0"])
      s.add_dependency(%q<shoulda-context>, [">= 0"])
      s.add_dependency(%q<rdoc>, ["~> 3.12"])
      s.add_dependency(%q<bundler>, ["~> 1.0.0"])
      s.add_dependency(%q<jeweler>, ["~> 1.8.3"])
      s.add_dependency(%q<turn>, ["~> 0.8.2"])
      s.add_dependency(%q<minitest>, [">= 0"])
      s.add_dependency(%q<ansi>, ["~> 1.2.5"])
    end
  else
    s.add_dependency(%q<redis>, [">= 0"])
    s.add_dependency(%q<i18n>, ["~> 0.6.0"])
    s.add_dependency(%q<activesupport>, ["~> 3.1.0"])
    s.add_dependency(%q<rake>, [">= 0"])
    s.add_dependency(%q<rack>, ["~> 1.3.0"])
    s.add_dependency(%q<shoulda>, [">= 0"])
    s.add_dependency(%q<shoulda-context>, [">= 0"])
    s.add_dependency(%q<rdoc>, ["~> 3.12"])
    s.add_dependency(%q<bundler>, ["~> 1.0.0"])
    s.add_dependency(%q<jeweler>, ["~> 1.8.3"])
    s.add_dependency(%q<turn>, ["~> 0.8.2"])
    s.add_dependency(%q<minitest>, [">= 0"])
    s.add_dependency(%q<ansi>, ["~> 1.2.5"])
  end
end

