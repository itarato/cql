# frozen_string_literal: true

module CqlRuby
  def self.log(txt)
    p txt
  end
end

require 'cql_ruby/defs'
require 'cql_ruby/executor'
require 'cql_ruby/crumb_collector'
require 'cql_ruby/abstract_printer'
require 'cql_ruby/console_printer'
require 'cql_ruby/filter_reader'
require 'cql_ruby/filters/assignments'
require 'cql_ruby/filter_evaluator'
require 'cql_ruby/pattern_matcher'
