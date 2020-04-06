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
  
  s.add_dependency('rest-client')
end