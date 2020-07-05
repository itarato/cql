# frozen_string_literal: true

module CQL
  module Filter
    ALL_TYPE = []
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
    def initialize(raw_filters)
      super()

      @allowed_types = CQL::Filter::ALL_TYPE

      parse_raw_filters(raw_filters)
    end

    private

    # @param [Array<String>] raw_filters
    def parse_raw_filters(raw_filters)
      raw_filters.each do |raw_filter|
        name, value = raw_filter.split(':')
        raise "Unrecognized filter: #{raw_filter}" if name.nil? || value.nil?

        if %w[type].include?(name)
          @allowed_types = value.split(',').map(&:to_sym)
        end
      end

      nil
    end
  end
end
