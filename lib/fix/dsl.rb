# frozen_string_literal: true

require_relative "spec"

module Fix
  # Public interface.
  class Dsl
    def self.before(&block)
      define_method(:initialize) do |*args, **kwargs|
        super()
        instance_exec(*args, **kwargs, &block)
      end
    end

    def self.describe(object, &block)
      s = Spec.const_set(object.class.name, ::Class.new(self))
      s.instance_exec(object, &block)
      s
    end

    def self.it(&block)
      define_method("test_#{block.object_id}".to_sym) do |*args, **kwargs|
        i = It.new
        i.instance_exec(*args, **kwargs, &block)
      end
    end

    def self.let(identifier, &block)
      protected define_method(identifier, &block)
    end
  end
end
