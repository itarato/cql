# frozen_string_literal: true

module CqlRuby
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
    class HierarchyPattern
      SELF_MARKER = 'X'

      def self.from(raw_value)
        parts = raw_value.split('-')
        self_marker_idx = parts.index(SELF_MARKER)
        raise "Missing self marker '#{SELF_MARKER}' in hierarchy pattern." if self_marker_idx.nil?

        ancestors = parts[0...self_marker_idx]
        descendants = parts[self_marker_idx + 1..]

        new(ancestors, descendants)
      end

      attr_reader :ancestors
      attr_reader :descendants

      def initialize(ancestors, descendants)
        @ancestors = ancestors
        @descendants = descendants
      end
    end

    class NodeSpec < Struct.new(:type, :name)
      class << self
        #
        # @param [String] raw_value
        #   Format: TYPE(=NAME|=*)
        #   Accepted types: class, module, def, block
        #
        def from(raw_value)
          type, name = raw_value.split('=')
          name ||= CqlRuby::MATCH_ANYTHING

          raise "Type '#{type}' is not recognized. See 'cql_ruby --help' for allowed types." unless Parser::Meta::NODE_TYPES.member?(type.to_sym)

          new(type, name)
        end
      end

      def restrict_name?
        name != CqlRuby::MATCH_ANYTHING
      end
    end

    NESTING_ALLOWED_TYPES = %w[class module def block].freeze

    # @attribute [Array<Symbol>] allowed_types
    attr_reader :allowed_types
    # @attribute [Array<CqlRuby::FilterReader::NodeSpec>] nest_under
    attr_reader :nest_under
    # @attribute [Array<CqlRuby::FilterReader::NodeSpec>] has_leaves
    attr_reader :has_leaves
    # @attribute [Array<CqlRuby::FilterReader::HierarchyPattern>] patterns
    attr_reader :patterns
    # @attribute [Boolean] is_assigned
    attr_reader :is_assigned

    def initialize(raw_filters = [])
      super()

      @allowed_types = []
      @nest_under = []
      @has_leaves = []
      @patterns = []
      @is_assigned = false

      parse_raw_filters(raw_filters)
    end

    def restrict_types?
      !@allowed_types.empty?
    end

    def restrict_nesting?
      !@nest_under.empty?
    end

    def restrict_children?
      !@has_leaves.empty?
    end

    def restrict_pattern?
      !@patterns.empty?
    end

    def restrict_assignment?
      @is_assigned
    end

    private

    # @param [Array<String>] raw_filters
    def parse_raw_filters(raw_filters)
      raw_filters.each do |raw_filter|
        name, value = raw_filter.split(':')
        raise "Unrecognized filter: #{raw_filter}" if name.nil?

        if %w[type t].include?(name)
          @allowed_types += value.split(',').map(&:to_sym)
        elsif %w[nest n].include?(name)
          spec = NodeSpec.from(value)
          raise "Unknown type for nesting: '#{spec.type}' from '#{raw_filter}'. Allowed: #{NESTING_ALLOWED_TYPES}" unless NESTING_ALLOWED_TYPES.include?(spec.type)
          raise "Type #{spec.type} cannot have a name." if %w[block].include?(spec.type) && spec.restrict_name?

          @nest_under << spec
        elsif %w[has h].include?(name)
          @has_leaves << NodeSpec.from(value)
        elsif %w[pattern p].include?(name)
          @patterns << HierarchyPattern.from(value)
        elsif name == 'assigned'
          @is_assigned = true
        end
      end

      nil
    end
  end
end
