Gem::Specification.new do |s|
  s.name = 'cql_ruby'
  s.summary = 'Code Query Language for Ruby'
  s.version = '0.0.15'
  s.required_ruby_version = '>= 2.5.0'
  s.date = '2020-07-05'
  s.files = Dir.glob('lib/**/*.rb')
  s.require_paths = ['lib']
  s.authors = ['itarato']
  s.email = 'it.arato@gmail.com'
  s.license = 'GPL-3.0-or-later'
  s.homepage = 'https://github.com/itarato/cql'
  s.executables << 'cql_ruby'
  s.add_runtime_dependency 'parser', '~> 2.7', '>= 2.7.1'
  s.add_development_dependency 'rspec'
end
