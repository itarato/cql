module CqlRuby
  module Filters
    class Assignments
      class << self
        #
        # @param [CqlRuby::FilterReader] filter_reader
        # @param [Array<Parser::AST::Node>] ancestors
        # @param [Parser::AST::Node] node
        #
        # @return [Boolean]
        #
        def pass?(filter_reader, ancestors, node)
          return true unless filter_reader.restrict_assignment?
          return true if lvar_assign?(ancestors, node)
          return true if instance_attr_assign?(ancestors, node)
          return true if array_sym_key_assign?(ancestors, node)
          return true if array_string_key_assign?(ancestors, node)
          return true if hash_sym_key_assign?(ancestors, node)
          return true if hash_string_key_assign?(ancestors, node)
          false
        end

        private

        #
        # @param [Array<Parser::AST::Node>] ancestors
        # @param [Parser::AST::Node] node
        #
        # @return [Boolean]
        #
        def lvar_assign?(ancestors, node)
          pattern_pass?({
            nth_child: 0,
            parent: {
              type: :lvasgn
            }
          }, ancestors, node)
        end

        # TODO This does not work as symbol token is suffixed with =, eg foo= for bar.foo = x.
        # Workaround for now is to use a =-alloed pattern, such as 'r/^token(|=)$/'
        def instance_attr_assign?(ancestors, node)
          pattern_pass?({
            nth_child: 1,
            parent: {
              type: :send
            }
          }, ancestors, node)
        end

        def array_sym_key_assign?(ancestors, node)
          pattern_pass?({
            nth_child: 0,
            parent: {
              type: :sym,
              nth_child: 2,
              parent: {
                type: :send,
                child: {
                  nth: 1,
                  token: :[]=
                }
              }
            }
          }, ancestors, node)
        end

        def array_string_key_assign?(ancestors, node)
          pattern_pass?({
            nth_child: 0,
            parent: {
              type: :str,
              nth_child: 2,
              parent: {
                type: :send,
                child: {
                  nth: 1,
                  token: :[]=
                }
              }
            }
          }, ancestors, node)
        end

        def hash_sym_key_assign?(ancestors, node)
          pattern_pass?({
            nth_child: 0,
            parent: {
              type: :sym,
              nth_child: 0,
              parent: {
                type: :pair,
                parent: {
                  type: :hash
                }
              }
            }
          }, ancestors, node)
        end

        def hash_string_key_assign?(ancestors, node)
          pattern_pass?({
            nth_child: 0,
            parent: {
              type: :str,
              nth_child: 0,
              parent: {
                type: :pair,
                parent: {
                  type: :hash
                }
              }
            }
          }, ancestors, node)
        end

        def pattern_pass?(pattern, ancestors, node)
          ancestor_idx = ancestors.size
          current_node = node
          current_pattern = pattern

          loop do
            if current_pattern.key?(:nth_child)
              return false unless ancestor_idx - 1 >= 0
              return false unless ancestors[ancestor_idx - 1].is_a?(Parser::AST::Node)
              return false unless ancestors[ancestor_idx - 1].children[current_pattern[:nth_child]] == current_node
            end

            if current_pattern.key?(:type)
              return false unless current_node.type == current_pattern[:type]
            end

            if current_pattern.key?(:child)
              return false if current_node.children.size <= current_pattern[:child][:nth]
              return false unless current_node.children[current_pattern[:child][:nth]] == current_pattern[:child][:token]
            end

            break unless current_pattern.key?(:parent)

            ancestor_idx -= 1
            return false unless ancestor_idx >= 0
            current_node = ancestors[ancestor_idx]
            current_pattern = current_pattern[:parent]
          end

          true
        end
      end
    end
  end
end