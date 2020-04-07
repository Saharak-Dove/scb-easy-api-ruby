require File.expand_path('../lib/scb_easy_api/version', __FILE__)

Gem::Specification.new do |s|
  s.name        = 'scb_easy_api'
  s.version     = ScbEasyApi::VERSION
  s.date        = '2020-04-06'
  s.summary     = 'For scb payment gateway api'
  s.description = 'For scb payment gateway api'
  s.authors     = ['Saharak Manoo']
  s.email       = 'Saharakmanoo@outlook.com'
  s.files       = ["lib/scb_easy_api.rb", "lib/scb_easy_api/client.rb"]
  s.homepage    = 'https://github.com/Saharak-Dove/scb-easy-api-ruby'
  s.license     = 'MIT'
  s.executables << 'scb_easy_api'

  s.add_dependency('rest-client', '~> 2.0.1')

  s.add_development_dependency 'addressable', '~> 2.3'
  s.add_development_dependency 'bundler', '~> 1.11'
  s.add_development_dependency 'rake', '~> 13.0'
  s.add_development_dependency 'rspec', '~> 3.0'
  s.add_development_dependency 'webmock', '~> 3.8'
end