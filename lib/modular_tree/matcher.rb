module Tree
  class AbstractMatcher
    def match(node) = abstract_method

    def |(other) = MatchExpression::OrExpr.new(self, other)
    def &(other) = MatchExpression::AndExpr.new(self, other)
    def !() = MatchExpression::NegationExpr.new(self)
  end
  
  class Matcher < AbstractMatcher
    def match(node) = match?(node)

    def match?(node)
      case @expr
        when Proc
          @expr.call(node)
        when Symbol
          node.respond_to?(@expr) && node.send(@expr)
        when Class
          node.is_a? @expr
        when Array
          @expr.any? { |klass| node.is_a? klass }
        when true, false
          @expr
      else
        raise ArgumentError, @expr.inspect
      end
    end

    def initialize(expr = nil, &block)
      constrain expr, Proc, Symbol, Class, [Class], true, false, nil
      expr.nil? == block_given? or raise ArgumentError, "Expected either an argument or a block"
      @expr = (expr.nil? ? block : expr)
    end

    def self.new(expr = nil, *args, &block)
      expr.is_a?(AbstractMatcher) ? expr : super
    end
  end

  module MatchExpression
    class BinaryExpr < AbstractMatcher
      def initialize(left, right)
        constrain left, Matcher
        constrain right, Matcher
        @left, @right = left, right
      end
    end

    class AndExpr < BinaryExpr
      def match?(node) = @left.match?(node) && @right.match?(node)
    end

    class OrExpr < BinaryExpr
      def match?(node) = @left.match?(node) || @right.match?(node) ? true : false
    end

    class NegationExpr < AbstractMatcher
      def initialize(matcher) = @matcher = matcher
      def match?(node) = !@matcher.match?(node)
    end
  end
end

