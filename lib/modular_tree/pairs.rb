module Tree
  class Pairs < Enumerator
    def group
      h = {}
      each { |first, last| (h[first] ||= []) << last }
      h.each
    end

    # Turn into a nested array tree
    def fold = abstract_method

    def to_h = abstract_method
  end
end
