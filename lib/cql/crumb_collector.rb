# frozen_string_literal: true

module CQL
  class CrumbCollector
    #
    # @param printer [CQL::AbstractPrinter]
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
