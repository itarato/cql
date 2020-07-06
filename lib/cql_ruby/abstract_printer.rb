# frozen_string_literal: true

module CqlRuby
  #
  # Printing Cqlruby::Crumb-s.
  #
  class AbstractPrinter
    def print(_crumb)
      raise NotImplementedError
    end
  end
end
