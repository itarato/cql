# frozen_string_literal: true

module CqlRuby;
  def self.log(txt)
    p txt
  end
end

Dir.glob(File.dirname(__FILE__) + '/cql_ruby/*.rb').each { |source| require source }
