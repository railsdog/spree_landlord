# encoding: UTF-8
Gem::Specification.new do |s|
  s.platform    = Gem::Platform::RUBY
  s.name        = 'spree_landlord'
  s.version     = '1.2.0'
  s.summary     = 'TODO: Add gem summary here'
  s.description = 'TODO: Add (optional) gem description here'
  s.required_ruby_version = '>= 1.8.7'

  s.author    = ['John Dilts', 'M. Scott Ford']
  s.email     = ['iam@hybridindie.com', 'scott@mscottford.com']

  s.files       = `git ls-files`.split("\n")
  s.test_files  = `git ls-files -- {spec}/*`.split("\n")
  s.require_path = 'lib'
  s.requirements << 'none'

  s.add_dependency 'spree_core', '~> 1.3.1'
# TODO: uncomment when we get a fixed published version
#  s.add_dependency 'spree_auth_devise', '~> 1.3.1'
  s.add_dependency 'spree_promo', '~> 1.3.1'
  s.add_development_dependency 'ffaker', '~> 1.12.1'

  s.add_development_dependency 'capybara', '1.0.1'
  s.add_development_dependency 'factory_girl', '~> 2.6.4'
  s.add_development_dependency 'rspec-rails',  '~> 2.9'
  s.add_development_dependency 'sqlite3'
  s.add_development_dependency 'spree_sample', '~> 1.3.1'
end
