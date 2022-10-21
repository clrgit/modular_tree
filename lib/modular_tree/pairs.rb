module Tree
  class Pairs < Enumerator
    def group
      h = {}
      each { |first, last| (h[first] ||= []) << last }
      h.each
    end
  end
end
