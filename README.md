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
