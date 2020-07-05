# frozen_string_literal: true

module CQL
  #
  # Printing CQL::Crumb-s.
  #
  class AbstractPrinter
    def print(_crumb)
      raise NotImplementedError
    end
  end
end
