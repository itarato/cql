# frozen_string_literal: true

require 'parser/current'

#
# Executes search and dumps results into the collector.
#
# @param collector [CQL::CrumbCollector]
# @param pattern [String]
# @param path [String]
# @param filters [Array<String>]
#
CQL::Executor = Struct.new(:collector, :filter_reader, :pattern, :path, :filters) do
  def search_all
    files.flat_map do |file|
      search(file)
    end
  end

  private

  def search(file)
    ast = Parser::CurrentRuby.parse(File.read(file))
    source_reader = CQL::SourceReader.new(file)
    walk(ast, [], source_reader)

    nil
  end

  def walk(node, ancestors, source_reader)
    if node.is_a?(::Parser::AST::Node)
      node.children.flat_map do |child|
        walk(child, ancestors.dup + [node], source_reader)
      end
    else
      if match?(node) && CQL::FilterEvaluator.pass?(filter_reader, node, ancestors)
        collector.add(CQL::Crumb.new(node, ancestors, source_reader))
      end
    end

    nil
  end

  def match?(target)
    # TODO make it partial and regex
    target.to_s == pattern
  end

  def files
    Dir.glob(path)
  end
end

CQL::Crumb = Struct.new(:full_name, :ancestors, :source_reader) do
  def line_no
    ancestors.last.location.expression.line
  end

  def line_col_no
    ancestors.last.location.expression.column
  end

  def source
    source_reader.source_line(line_no)
  end

  def file_name
    source_reader.file
  end

  def expression_size
    ancestors.last.location.expression.size
  end
end

CQL::SourceReader = Struct.new(:file) do
  def initialize(*args)
    super
  end

  def source_line(n)
    lines[n - 1].chop
  end

  private

  def lines
    @lines ||= IO.readlines(file)
  end
end
