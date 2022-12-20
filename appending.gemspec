Gem::Specification.new do |s|
  s.name        = 'appending'
  s.version     = '1.0'
  s.date        = '2022-12-20'
  s.summary     = "Appending is a Ruby gem for data enrichment of people and companies."
  s.description = "Appending is a Ruby gem for data enrichment of people and companies."
  s.authors     = ["Leandro Daniel Sardi"]
  s.email       = 'leandro.sardi@expandedventure.com'
  s.files       = [
    'lib/appending.rb',
  ]
  s.homepage    = 'https://rubygems.org/gems/appending'
  s.license     = 'MIT'
  s.add_runtime_dependency 'csv', '~> 3.2.2', '>= 3.2.2'
  s.add_runtime_dependency 'email_verifier', '~> 0.1.0', '>= 0.1.0'
  s.add_runtime_dependency 'blackstack-core', '~> 1.2.3', '>= 1.2.3'
  s.add_runtime_dependency 'blackstack-nodes', '~> 1.2.11', '>= 1.2.11'
  s.add_runtime_dependency 'blackstack-deployer', '~> 1.2.24', '>= 1.2.24'
  s.add_runtime_dependency 'simple_command_line_parser', '~> 1.1.2', '>= 1.1.2'
  s.add_runtime_dependency 'simple_cloud_logging', '~> 1.2.2', '>= 1.2.2'
  s.add_runtime_dependency 'csv-indexer', '~> 1.0.2', '>= 1.0.2'
end