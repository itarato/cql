# frozen_string_literal: true

module CQL
  #
  # Prints to console.
  #
  class ConsolePrinter < ::CQL::AbstractPrinter
    attr_writer :color_on
    attr_writer :file_on
    attr_writer :source_on

    def initialize
      super

      @color_on = true
      @file_on = true
      @source_on = true
    end

    #
    # @param crumb [CQL::Crumb]
    #
    def print(crumb)
      puts "#{color(94)}#{crumb.file_name}#{decor_reset}:#{color(33)}#{crumb.line_no}#{decor_reset} #{color(93)}#{crumb.type}#{decor_reset}" if @file_on
      puts decorate_source_line(crumb) if @source_on
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

    # @param [CQL::Crumb] crumb
    # @return [String]
    def decorate_source_line(crumb)
      # TODO add +- line surrounding options
      source = crumb.source
      from = crumb.line_col_no
      to = from + crumb.expression_size

      prefix = source[0..from - 1] || ''
      subject = source[from..to - 1] || ''
      suffix = source[to..] || ''

      color(90) +
        prefix +
        decor_reset +
        color(31) +
        bold +
        subject +
        decor_reset +
        color(90) +
        suffix +
        decor_reset
    end
  end
end
