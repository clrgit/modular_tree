
module ModularTree
  # Doesn't work atm. because DownTreeAlgorithms methods are implemented as
  # members and not as class methods and perhaps because of other stuff
  class TreeArray < AbstractTree
    include DownTreeAlgorithms

    attr_reader :array

    def node = array.first
    def children = array[1..-1]

    def initialize(array)
      @array = array
    end

    def self.filter(*args) = DownTreeAlgorithms.filter(*args)
  end
end
