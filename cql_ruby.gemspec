Gem::Specification.new do |s|
  s.name = 'cql_ruby'
  s.summary = 'Code Query Language for Ruby'
  s.version = '0.0.10'
  s.required_ruby_version = '>= 2.5.0'
  s.date = '2020-07-05'
  s.files = [
    'lib/cql_ruby.rb',
    'lib/cql_ruby/executor.rb',
    'lib/cql_ruby/crumb_collector.rb',
    'lib/cql_ruby/abstract_printer.rb',
    'lib/cql_ruby/console_printer.rb',
    'lib/cql_ruby/filter_reader.rb',
    'lib/cql_ruby/filter_evaluator.rb',
    'lib/cql_ruby/pattern_matcher.rb',
  ]
  s.require_paths = ['lib']
  s.authors = ['itarato']
  s.email = 'it.arato@gmail.com'
  s.license = 'GPL-3.0-or-later'
  s.homepage = 'https://github.com/itarato/cql'
  s.executables << 'cql_ruby'
  s.add_runtime_dependency 'parser', '~> 2.7', '>= 2.7.1'
end
