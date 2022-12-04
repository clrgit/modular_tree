# ModularTree

A modular tree implementation for Ruby

## Usage

```ruby
require "modular_tree"

class Node < Tree::Tree
  attr_reader :name
  def initialize(parent, name)
    @name = name
    super(parent)
  end
  def to_s(name)
end

root = Node.new(nil, "root")
a = Node.new(root, "a")
b = Node.new(root, "b")

puts root.children.join(', ') # a, b
puts a.parent                 # root


## Description

ModularTree classes are defined by using a set of modules that can be divided
into the following categories:

  * Property modules
  * Implementation modules
  * Algorithms modules

Property modules defines abstract properties that are defined by the
implementation modules while algorithms are defined in terms of properties.
This decouples algorithms and implementations and makes it possible to use the
same algorithms on different tree implementations

## Block arguments

Blocks are called with three arguments - value, key, and parent - but
usually only 'value' is used (Ruby allows you to ignore the remaining
arguments)

Keys may be nil if the underlying data structure doesn't support
them efficiently. Keys for array implementations are the node indexes. Note
that keys are only unique if you don't apply filters because filters may
combine nodes from different parents

Algorithms are supposed to take care of traversing the tree so blocks are
called with the values and not the tree node. This makes a difference for
external implementations where the values don't know their position in
the tree

If you don't need the keys, then the node/parent combination is already covered
by #edges

## External data structures

### Hash

```ruby
  {
    "root" => {
      "a" => {
        "b" => {},
        "c" => {}
      },
      "d" => {
        "e" => {}
      }
    }
  }
```

`#value` returns the hash value of a node. Eg. {"e"=>{}} if called on the "d" node

\#each_branch & #each_child will be called with

```ruby
  {...}, "root"
  {...}, "a"
  {}, "b"
  {}, "c"
  {...}, "d"
  {}, "e"
```

### Nested Array

```ruby
  [
    ["root", [
      ["a", [
        ["b", []],
        ["c", []]
      ]],
      ["d", [
        ["e", []]
      ]]
    ]]
  ]
```

`#value` returns first element in each node tuple. Eg. "d" if called on the "d" node


\#each_child will be called with

```ruby
"root", 0
"a", 0
"b", 0
"c", 1
"d", 1
"e", 0
```

\#each_branch will be called with

```ruby
["root", [...]], 0
["a", [...]], 0
["b", []], 0
["c", []], 1
["d", [...]], 1
["e", []], 0


Note that nested arrays is a structural representation where the "key" is the
real objects the tree is made of while hashes are maps from a value to the
object modelled as a hash. Hash trees have keys (typically strings) while
nested arrays has integer indexes as keys

## Installation

Install the gem and add to the application's Gemfile by executing:

    $ bundle add modular_tree

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install modular_tree

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/modular_tree.
