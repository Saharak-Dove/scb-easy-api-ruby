Gem::Specification.new do |s|
  s.name        = 'scb_easy_api'
  s.version     = '0.0.5'
  s.date        = '2020-04-06'
  s.summary     = 'For scb payment gateway api'
  s.description = 'For scb payment gateway api'
  s.authors     = ['Saharak Manoo']
  s.email       = 'Saharakmanoo@outlook.com'
  s.files       = ["lib/scb_easy_api.rb", "lib/scb_easy_api/client.rb"]
  s.homepage    = 'https://rubygems.org/gems/scb_easy_api'
  s.license     = 'MIT'
  s.add_dependency('rest-client')
end