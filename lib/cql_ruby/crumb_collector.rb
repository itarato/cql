# frozen_string_literal: true

module CqlRuby
  class CrumbCollector
    #
    # @param printer [CqlRuby::AbstractPrinter]
    #
    def initialize(printer)
      super()

      @printer = printer
    end

    def add(crumb)
      @printer.print(crumb)
    end
  end
end
