# frozen_string_literal: true

module CqlRuby
  class FilterEvaluator
    class << self
      def pass?(filter_reader, ancestors)
        [
          pass_type?(filter_reader, ancestors),
          pass_nesting?(filter_reader, ancestors),
          pass_has?(filter_reader, ancestors),
        ].all?
      end

      private

      #
      # @param [Cqlruby::FilterReader] filter_reader
      # @param [Array<Parser::AST::Node>] ancestors
      #
      # @return [Boolean]
      #
      def pass_type?(filter_reader, ancestors)
        return true unless filter_reader.restrict_types?

        filter_reader.allowed_types.include?(ancestors.last.type)
      end

      #
      # @param [CqlRuby::FilterReader] filter_reader
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

            if %w[class module].include?(nest_rule.type)
              CqlRuby::PatternMatcher.match?(nest_rule.name, ancestor.children[0].children[1])
            elsif %[def].include?(nest_rule.type)
              CqlRuby::PatternMatcher.match?(nest_rule.name, ancestor.children[0])
            else
              raise 'Unknown type.'
            end
          end
        end
      end

      #
      # @param [CqlRuby::FilterReader] filter_reader
      # @param [Array<Parser::AST::Node>] ancestors
      #
      def pass_has?(filter_reader, ancestors)
        return true unless filter_reader.restrict_children?

        filter_reader.has_leaves.all? do |has_rule|
          anchor_node = try_get_class(ancestors) || try_get_module(ancestors) || try_get_def(ancestors)
          next false unless anchor_node

          has_node_with_name?(anchor_node, has_rule)
        end
      end

      #
      # @param [Array<Parser::AST::Node>] ancestors
      #
      def try_get_class(ancestors)
        return nil unless ancestors.size >= 2
        return nil unless ancestors[-1].type == :const
        return nil unless ancestors[-2].type == :class

        ancestors[-2].children[2]
      end

      #
      # @param [Array<Parser::AST::Node>] ancestors
      #
      def try_get_module(ancestors)
        return nil unless ancestors.size >= 2
        return nil unless ancestors[-1].type == :const
        return nil unless ancestors[-2].type == :module

        ancestors[-2].children[1]
      end

      #
      # @param [Array<Parser::AST::Node>] ancestors
      #
      def try_get_def(ancestors)
        return nil unless ancestors.size >= 1
        return nil unless ancestors[-1].type == :def

        ancestors[-1].children[2]
      end

      #
      # @param [Parser::AST::Node] anchor_node
      # @param [CqlRuby::NodeSpec]
      #
      def has_node_with_name?(anchor_node, has_rule)
        return false unless anchor_node.is_a?(Parser::AST::Node)

        fn_children_with_type = ->(node) { node.children.map { |child| [child, node.type] } }
        to_visit = fn_children_with_type.call(anchor_node)

        until to_visit.empty?
          current_node, current_type = to_visit.shift

          if current_node.is_a?(Parser::AST::Node)
            to_visit += fn_children_with_type.call(current_node)
          else
            if current_type == has_rule.type.to_sym && CqlRuby::PatternMatcher.match?(has_rule.name, current_node)
              return true
            end
          end
        end

        false
      end
    end
  end
end
