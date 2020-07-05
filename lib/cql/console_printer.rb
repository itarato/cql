# frozen_string_literal: true

module CQL
  #
  # Prints to console.
  #
  class ConsolePrinter < ::CQL::AbstractPrinter
    #
    # @param crumb [CQL::Crumb]
    #
    def print(crumb)
      puts "\e[94m#{crumb.file_name}\e[0m:\e[33m#{crumb.line_no}\e[0m"
      puts colorize_source_line(crumb)
    end

    private

    # @param [CQL::Crumb] crumb
    # @return [String]
    def colorize_source_line(crumb)
      source = crumb.source
      from = crumb.line_col_no
      to = from + crumb.expression_size

      prefix = source[0..from - 1] || ''
      subject = source[from..to - 1] || ''
      suffix = source[to..] || ''

      "\e[90m" + prefix + "\e[0m\e[31m\e[1m" + subject + "\e[0m\e[90m" + suffix + "\e[0m"
    end
  end
end
