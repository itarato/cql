# frozen_string_literal: true

module CqlRuby
  class NestRule < Struct.new(:type, :name)
    NAME_ANY = '*'
    ALLOWED_TYPE = %w[class module def block].freeze

    class << self
      #
      # @param [String] raw_value
      #   Format: TYPE(=NAME|=*)
      #   Accepted types: class, module, def, block
      #
      def from(raw_value)
        type, name = raw_value.split('=')
        name ||= NAME_ANY

        raise "Unknown type: #{type}. Allowed: #{ALLOWED_TYPE}" unless ALLOWED_TYPE.include?(type)
        raise "Type #{type} cannot have a name." if %w[block].include?(type) && name != NAME_ANY

        new(type, name)
      end
    end

    def restrict_name?
      name != NAME_ANY
    end
  end

  #
  # Reads and provides filters.
  #
  # Accepted filters and syntax:
  #
  # Type:
  #
  # type:[name](,[name])*
  # example: type:def,send
  #
  class FilterReader
    # @attribute [Parser::AST::Node] allowed_types
    attr_reader :allowed_types
    # @attribute [Array<Cqlruby::NestRule>] nest_under
    attr_reader :nest_under

    def initialize(raw_filters)
      super()

      @allowed_types = []
      @nest_under = []

      parse_raw_filters(raw_filters)
    end

    def restrict_types?
      !@allowed_types.empty?
    end

    def restrict_nesting?
      !@nest_under.empty?
    end

    private

    # @param [Array<String>] raw_filters
    def parse_raw_filters(raw_filters)
      raw_filters.each do |raw_filter|
        name, value = raw_filter.split(':')
        raise "Unrecognized filter: #{raw_filter}" if name.nil? || value.nil?

        if %w[type t].include?(name)
          @allowed_types += value.split(',').map(&:to_sym)
        elsif %w[nest n].include?(name)
          @nest_under << NestRule.from(value)
        end
      end

      nil
    end
  end
end
