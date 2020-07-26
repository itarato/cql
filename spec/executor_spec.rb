require_relative '../lib/cql_ruby'
require 'pathname'
require 'pry-byebug'

describe CqlRuby::Executor do
  describe 'search_all' do
    it 'Smoke#1 - does a token search' do
      printer = double(CqlRuby::ConsolePrinter.new)
      expect(printer).to(receive(:print))
      collector = CqlRuby::CrumbCollector.new(printer)
      filter_reader = CqlRuby::FilterReader.new
      executor = CqlRuby::Executor.new(
        collector: collector,
        filter_reader: filter_reader,
        pattern: 'Hello',
        path: File.dirname(Pathname(__FILE__ ).cleanpath.to_s) + '/../spec_samples/sample1.rb',
      )

      executor.search_all
    end
  end
end
