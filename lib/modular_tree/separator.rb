module Tree
  module Separator
    DEFAULT_SEPARATOR = "."

    def self.included(other)
      puts "including Separator"
      super(other)
      other.instance_variable_set(:@separator, DEFAULT_SEPARATOR)
      other.extend(ClassMethods)
    end

    def separator
      self.class.instance_variable_get(:@separator)
    end

    module ClassMethods
      attr_accessor :separator
      def split(s) = s.split /#{separator}/
    end
  end
end
