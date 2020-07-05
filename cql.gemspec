Gem::Specification.new do |s|
  s.name = 'cql'
  s.summary = 'Code Query Language'
  s.version = '0.0.4'
  s.date = '2020-07-04'
  s.files = [
      'lib/cql.rb',
      'lib/cql/executor.rb',
      'lib/cql/crumb_collector.rb',
      'lib/cql/abstract_printer.rb',
      'lib/cql/console_printer.rb',
  ]
  s.require_paths = ['lib']
  s.authors = ['itarato']
  s.license = 'GPL-3.0-or-later'
  s.homepage = 'https://github.com/itarato'
end
