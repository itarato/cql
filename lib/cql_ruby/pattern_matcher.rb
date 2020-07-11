# frozen_string_literal: true
module CqlRuby
  module PatternMatcher
    MATCH_ANY = '*'

    def self.match?(pattern, subject)
      pattern = pattern.to_s
      return true if pattern == MATCH_ANY

      subject = subject.to_s

      if regex?(pattern)
        regex_match?(pattern, subject)
      elsif partial_string?(pattern)
        partial_string_match?(pattern, subject)
      else
        full_string_match?(pattern, subject)
      end
    end

    def self.regex?(pattern)
      pattern[0..1] == 'r/'
    end
    private_class_method :regex?

    def self.partial_string?(pattern)
      pattern[0] == '%'
    end
    private_class_method :partial_string?

    def self.regex_match?(pattern, subject)
      pattern = pattern[2..]
      delim_idx = pattern.rindex('/')
      mods = pattern[delim_idx + 1..].chars
      pattern = pattern[0..delim_idx - 1]

      fops = 0
      fops |= Regexp::IGNORECASE if mods.include?('i')
      fops |= Regexp::MULTILINE if mods.include?('m')
      fops |= Regexp::EXTENDED if mods.include?('x')
      fops |= Regexp::FIXEDENCODING if mods.include?('f')
      fops |= Regexp::NOENCODING if mods.include?('n')
      Regexp.new(pattern, fops).match?(subject)
    end
    private_class_method :regex_match?

    def self.full_string_match?(pattern, subject)
      pattern == subject
    end
    private_class_method :full_string_match?

    def self.partial_string_match?(pattern, subject)
      !subject.index(pattern[1..]).nil?
    end
    private_class_method :partial_string_match?
  end
end
