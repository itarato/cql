# frozen_string_literal: true

module CQL
  class FilterEvaluator
    class << self
      def pass?(filter_reader, node, ancestors)
        [
          pass_type?(filter_reader, ancestors),
          pass_nesting?(filter_reader, ancestors),
        ].all?
      end

      private

      #
      # @param [CQL::FilterReader] filter_reader
      # @param [Array<Parser::AST::Node>] ancestors
      #
      # @return [Boolean]
      #
      def pass_type?(filter_reader, ancestors)
        return true unless filter_reader.restrict_types?

        filter_reader.allowed_types.include?(ancestors.last.type)
      end

      #
      # @param [CQL::FilterReader] filter_reader
      # @param [Array<Parser::AST::Node>] ancestors
      #
      # @return [Boolean]
      #
      def pass_nesting?(filter_reader, ancestors)
        return true unless filter_reader.restrict_nesting?

        filter_reader.nest_under.all? do |nest_rule|
          ancestors.reverse.any? do |ancestor|
            next false unless ancestor.type.to_s == nest_rule.type
            next true unless nest_rule.restrict_name?

            # TODO Make a proper matcher class.
            if %w[class module].include?(nest_rule.type)
              ancestor.children[0].children[1].to_s == nest_rule.name
            elsif %[def].include?(nest_rule.type)
              ancestor.children[0].to_s == nest_rule.name
            else
              raise 'Unknown type.'
            end
          end
        end
      end
    end
  end
end
