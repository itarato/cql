# frozen_string_literal: true

module CqlRuby
  #
  # Prints to console.
  #
  class ConsolePrinter < ::CqlRuby::AbstractPrinter
    attr_writer :color_on
    attr_writer :file_on
    attr_writer :source_on
    attr_writer :surrounding_lines

    def initialize
      super

      @color_on = true
      @file_on = true
      @source_on = true
      @surrounding_lines = 0
      @counter = 0
    end

    #
    # @param crumb [CqlRuby::Crumb]
    #
    def print(crumb)
      parts = "##{color(97)}#{@counter}#{decor_reset}"
      parts += " #{color(94)}#{crumb.file_name}#{decor_reset}:#{color(33)}#{crumb.line_no}#{decor_reset} #{color(93)}#{crumb.type}#{decor_reset}" if @file_on

      if @source_on && @surrounding_lines.positive?
        parts_visible_len = parts.gsub(/\e\[\d+m/, '').size + 1
        indent = ' ' * parts_visible_len
        (-@surrounding_lines).upto(-1).each { |offs| puts "#{indent}#{crumb.surrounding_line(offs)}" }
      end

      parts += ' ' + decorate_source_line(crumb) if @source_on

      puts parts

      if @source_on && @surrounding_lines.positive?
        1.upto(@surrounding_lines).each { |offs| puts "#{indent}#{crumb.surrounding_line(offs)}" }
        puts '--'
      end

      @counter += 1
    end

    private

    def color(code)
      if @color_on
        "\e[#{code}m"
      else
        ''
      end
    end

    def bold
      if @color_on
        "\e[1m"
      else
        ''
      end
    end

    def decor_reset
      if @color_on
        "\e[0m"
      else
        ''
      end
    end

    # @param [CqlRuby::Crumb] crumb
    # @return [String]
    def decorate_source_line(crumb)
      source = crumb.source
      from = crumb.line_col_no
      to = from + crumb.expression_size

      prefix = if from > 0
        source[0..from - 1] || ''
      else
        ''
      end
      subject = source[from..to - 1] || ''
      suffix = source[to..] || ''

      color(97) +
        prefix +
        decor_reset +
        color(31) +
        bold +
        subject +
        decor_reset +
        color(97) +
        suffix +
        decor_reset
    end
  end
end
