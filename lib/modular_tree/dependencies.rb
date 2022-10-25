require 'tsort'

module Tree
  module Dependencies
    @abstract_pool = {}
    @required_pool = {}
    @provided_pool = {}

    @recursively_required_pool = {}
    @recursively_provided_pool = {}

    def self.sort_modules(*modules)
      modules = Array(modules).flatten
      each_node = lambda { |&b| modules.each(&b) }
      each_child = lambda { |m, &b| required_modules(m).each(&b) }
      TSort.tsort(each_node, each_child)
    end

    def self.abstract_module(m)
      @abstract_pool[m] = true
    end

    def self.abstract?(m) @abstract_pool.key?(m) end

    def self.require_module(m, *modules)
      (@required_pool[m] ||= []).concat(Array(modules).flatten)
    end

    def self.required_modules(m)
      @required_pool[m] || []
    end

    def self.recursively_required_modules(m)
      @recursively_required_pool[m] ||= begin
        required_modules(m).map { |rm| [rm, recursively_required_modules(rm)] }.flatten
      end
    end

    def self.provide_module(m, *modules)
      (@provided_pool[m] ||= []).concat(Array(modules).flatten)
    end

    def self.provided_modules(m)
      @provided_pool[m] || []
    end

    def self.recursively_provided_modules(m)
      @recursively_provided_pool[m] ||= begin
        provided_modules(m) + required_modules(m).map { |rm| recursively_provided_modules(rm) }.flatten
      end
    end
    
    def self.all_provided_modules(m)
      (abstract?(m) ? [] : [m]) + 
          provided_modules(m) + required_modules(m).map { |rm| all_provided_modules(rm) }.flatten
    end





    # FIXME: Does order-of-inclusion matter anymore? The question is if the
    # no-abstract-methods-in-use-classes rule prevents implementations of
    # methods from being shadowed by abstract methods
    def self.use_module(m, *modules)
      constrain m, Module
      modules = Array(modules).flatten
      constrain modules, Module, [Module]
      modules.each { |m|
        m.respond_to?(:recursively_provided_modules, true) or
            raise ArgumentError, "Module '#{m}' does not include Tree::Tracker" 
      }

      puts "use_module #{m.inspect}"
      indent {
        puts "use"
        indent { puts modules }

        all_used_modules = modules.map { |m| 
          m.ancestors + m.included_modules
        }.flatten.reject { |m| m == Tree::Tracker }.sort { |l,r| l.to_s <=> r.to_s }.uniq

        puts "all_used_modules"
        indent { puts all_used_modules }

        all_required_modules = all_used_modules.map { |m|
          required_modules(m)
        }.flatten.uniq

        puts "all_required_modules"
        indent { puts all_required_modules }

        all_provided_modules = all_used_modules.map { |m|
          [m, provided_modules(m)]
        }.flatten.uniq

        puts "all_provided_modules"
        indent { puts all_provided_modules }

        diff = all_required_modules - all_provided_modules

        if diff.empty?
          puts "diff is empty"
        else
          puts "diff"
          indent { puts diff }
          raise ArgumentError, "Can't find required modules #{diff.inspect}"
        end

        sorted_modules = sort_modules(all_provided_modules)

        puts "sorted_modules"
        indent { puts sorted_modules }

        exit

        # Substitute provided modules with the provider and remove duplicates
        resolved_modules = sorted_modules.map { |m|
          r = m
          for um in use_modules
#           p um
            if recursively_provided_modules(um).include?(m)
#           if um.send(:recursively_provided_modules).include?(m)
              r = um
              break
            end
          end
          r     
        }.uniq

        puts "resolved: #{resolved_modules.inspect}"

        # List of modules to include
        include_modules = resolved_modules & use_modules

        if false
#       if true
        # Move first module with a one-argument initializer to the front
        found = nil
        include_modules.each { |m|
          if m.private_instance_methods.include?(:initialize)
            case m.instance_method(:initialize).arity 
              when 0
#               puts "FOUND ARITY 0"
                ;
              when 1
#               puts "FOUND"
                !found or raise ArgumentError, "More than one #initialize with an argument"
                found = m
              else
                raise ArgumentError, "Illegal number of arguments in #{m}#initialize"
            end
          end
        }
        if found
          include_modules.delete(found)
          include_modules = include_modules + [found]
        end
        end

        # Include modules
#       puts "include: #{include_modules.reverse.inspect}"
#       include_modules.reverse.each { |im| m.include(im) }

#       # Include modules
        puts "include: #{include_modules.inspect}"
        include_modules.each { |im| m.include(im) }


        
#       recursively_provided_methods



      }
    end

  end

  module Tracker
    def self.included(other)
      other.extend(ClassMethods)
      super
    end

#   def included(other)
#     modules = other.ancestors.map { |a| [a, Dependencies.provided_modules(a)] }.flatten
#     for m in required_modules
#       m == other || modules.include?(m) or raise ArgumentError, "#{self} requires module #{m}"
#     end
#     super
#   end

    def dump
      puts "self: #{self}"
      indent {
        puts "required_modules: #{required_modules.inspect}"
        puts "provided_modules: #{provided_modules.inspect}"
      }
    end

    def initialize(_parent)
#     puts "#{self.class}#initialize(#{parent.inspect})"
    end

    module ClassMethods
      def abstract?() = Dependencies.abstract?(self)

      def abstract_module() = Dependencies.abstract_module(self)
      def require_module(*modules) = Dependencies.require_module(self, modules)
      def provide_module(*modules) = Dependencies.provide_module(self, modules)
      def use_module(*modules) = Dependencies.use_module(self, *modules)

    protected
      def required_modules = Dependencies.required_modules(self)
      def recursively_required_modules = Dependencies.recursively_required_modules(self)

      def provided_modules = Dependencies.provided_modules(self)
      def recursively_provided_modules = Dependencies.recursively_provided_modules(self)
      def all_provided_modules = Dependencies.all_provided_modules(self)
      

    end
  end
end


