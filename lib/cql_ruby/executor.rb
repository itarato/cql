# frozen_string_literal: true

require 'parser/current'
require 'pathname'

module CqlRuby
  class Config
    @@debug_level = 0

    class << self
      def debug_level=(lvl); @@debug_level = lvl; end
      def debug_level; @@debug_level; end
      def debug_level_1?; @@debug_level >= 1; end
      def debug_level_2?; @@debug_level >= 2; end
      def debug_level_3?; @@debug_level >= 3; end
    end
  end
end

#
# Executes search and dumps results into the collector.
#
# @param collector [CqlRuby::CrumbCollector]
# @param pattern [String]
# @param path [String]
# @param filters [Array<String>]
#
module CqlRuby
  class Executor
    def initialize(
      collector:,
      filter_reader:,
      pattern:,
      path:,
      filters: [],
      recursive: true,
      include: nil,
      exclude: nil,
      search_type: :token
    )
      @collector = collector
      @filter_reader = filter_reader
      @pattern = pattern
      @path = path
      @filters = filters
      @recursive = recursive
      @include = include
      @exclude = exclude
      @search_type = search_type
    end

    def search_all
      files.flat_map do |file|
        next if !@exclude.nil? && CqlRuby::PatternMatcher.match?(@exclude, file)
        next unless @include.nil? || CqlRuby::PatternMatcher.match?(@include, file)

        CqlRuby.log "File check: #{file}" if CqlRuby::Config.debug_level_3?
        search(file)
      end
    end

    private

    def search(file)
      ast = Parser::CurrentRuby.parse(File.read(file))
      source_reader = CqlRuby::SourceReader.new(file)
      walk(ast, [], source_reader)

      nil
    rescue
      CqlRuby.log "File #{file} cannot be parsed"
      CqlRuby.log "Reason: #{$!}" if CqlRuby::Config.debug_level_1?
    end

    def walk(node, ancestors, source_reader)
      if node.is_a?(Parser::AST::Node)
        if search_for_node?
          if match?(node.type) && CqlRuby::FilterEvaluator.pass?(filter_reader, ancestors, node)
            collector.add(CqlRuby::Crumb.new(node, ancestors, source_reader))
          end
        end

        node.children.flat_map do |child|
          walk(child, ancestors.dup + [node], source_reader)
        end
      else
        if search_for_token? && match?(node) && CqlRuby::FilterEvaluator.pass?(filter_reader, ancestors, node)
          collector.add(CqlRuby::Crumb.new(node, ancestors, source_reader))
        end
      end

      nil
    end

    def match?(target)
      CqlRuby::PatternMatcher.match?(pattern, target)
    end

    def files
      return [path] if File.file?(path)

      clean_path = Pathname(path).cleanpath.to_s
      clean_path += '/**' if recursive
      clean_path += '/*.rb'

      Dir.glob(clean_path)
    end

    def search_for_token?
      @search_type == :token
    end

    def search_for_node?
      @search_type == :node
    end

    attr_reader :collector
    attr_reader :filter_reader
    attr_reader :pattern
    attr_reader :path
    attr_reader :filters
    attr_reader :recursive
  end
end

module CqlRuby
  class Crumb
    def initialize(node, ancestors, source_reader)
      @node = node
      @ancestors = ancestors
      @source_reader = source_reader
    end

    def line_no
      anchor.location.expression.line
    end

    def line_col_no
      anchor.location.expression.column
    end

    def source
      source_reader.source_line(line_no)
    end

    def surrounding_line(offset)
      source_reader.source_line(line_no + offset)
    end

    def file_name
      source_reader.file
    end

    def expression_size
      anchor.location.expression.size
    end

    def type
      anchor.type
    end

    private

    def anchor
      if node.is_a?(Parser::AST::Node)
        node
      else
        ancestors.last
      end
    end

    attr_reader :node
    attr_reader :ancestors
    attr_reader :source_reader
  end
end

CqlRuby::SourceReader = Struct.new(:file) do
  def initialize(*args)
    super
  end

  def source_line(n)
    return nil unless lines.size >= n

    lines[n - 1].chop
  end

  private

  def lines
    @lines ||= IO.readlines(file)
  end
end
