# frozen_string_literal: true

require "defi"
require "spectus"

require_relative "environment"
require_relative "level"
require_relative "matcher"
require_relative "node"

module Fix
  # The language of a specification. The block of `Fix :Name do … end` runs
  # on an instance of this class, thrown away afterwards, whose four words
  # build the contexts of the specification: `let`, `with`, `on` and `it`.
  # The matchers ({Fix::Matcher}) and the levels ({Fix::Level}) are words of
  # it too.
  #
  # A gem may add a word that composes these four: fix-its adds `its`.
  class Dsl
    include Level
    include Matcher

    # The four words.
    WORDS = %i[let with on it].freeze
    private_constant :WORDS

    # @yield the document of a specification
    # @return [Array<Fix::Node>] its contexts, each before its children
    def self.build(&)
      dsl = new({}.freeze, [].freeze, "")
      dsl.instance_exec(&)
      dsl.nodes.freeze
    end

    # @param lets [Hash{Symbol => Proc}] the lets inherited, frozen
    # @param challenges [Array<Defi::Challenge>] the chain inherited, frozen
    # @param chain [String] its text
    # @param own [Array<Symbol>] the lets this context declares already,
    #   those a `with` gave it
    # @api private
    def initialize(lets, challenges, chain, own = [])
      @lets = lets
      @challenges = challenges
      @chain = chain
      @own = own
      @expectations = []
      @children = []
    end

    # @return [Array<Fix::Node>] this context, then its children, as they
    #   stand
    def nodes
      node = Node.new(lets: @lets, challenges: @challenges, chain: @chain, expectations: @expectations.dup.freeze)
      [node] + @children
    end

    # A parameter of the subject: its block runs where the subject is built,
    # once per expectation, and may call other lets. A let is not visible
    # from an expectation.
    #
    # @param name [Symbol] its name, which is not a method of the environment
    #   nor a word of the language, and not a let of this context already
    # @yieldreturn [Object] its value
    # @return [nil]
    # @raise [ArgumentError] otherwise, or without a block
    def let(name, &block)
      raise ::ArgumentError, "a block must be given" unless block

      free!(name)
      raise ::ArgumentError, "#{name} is already a let of this context" if @own.include?(name)

      @own << name
      @lets = @lets.merge(name => block).freeze
      nil
    end

    # A context where lets take the values given: the objects themselves,
    # shared by the expectations of the context, which declares these lets.
    #
    # @param values [Hash{Symbol => Object}] the lets, by name
    # @yield the context
    # @return [nil]
    # @raise [ArgumentError] for a name a let could not take, without a value
    #   or without a block
    def with(**values, &block)
      raise ::ArgumentError, "a block must be given" unless block
      raise ::ArgumentError, "a with gives a value to a let: with(name: 1)" if values.empty?

      values.each_key { |name| free!(name) }
      lets = @lets.merge(values.transform_values { |value| -> { value } }).freeze
      context(lets, @challenges, @chain, values.keys, &block)
    end

    # A context about what a method of the subject returns, or raises: the
    # method is sent, with its arguments, to the value of the context above.
    # No block can be given to the method: the block is the context.
    #
    # @param name [Symbol] the method, followed by its positional and keyword
    #   arguments, as they would be written after it
    # @yield the context
    # @return [nil]
    # @raise [ArgumentError] when the name is not a Symbol, or without a block
    def on(name, *, **, &block)
      raise ::ArgumentError, "a block must be given" unless block

      challenge = ::Defi::Challenge.new(name, *, **)
      context(@lets, (@challenges + [challenge]).freeze, text("#{@chain}#{challenge}"), &block)
    end

    # An expectation: a requirement, built here and now with a level and a
    # matcher, at the line of the call.
    #
    # @param requirement [Spectus::Requirement] `MUST eq(1)`, say
    # @param location [Thread::Backtrace::Location, nil] where the expectation
    #   is written, for a word that composes `it`; the caller of `it` otherwise
    # @return [nil]
    # @raise [ArgumentError] without a requirement, or with a block
    # @raise [TypeError] when the `to_s` of the matcher is not a String
    def it(requirement = nil, location: nil, &block)
      raise ::ArgumentError, "it takes a requirement, not a block: it MUST eq(1)" if block
      raise ::ArgumentError, "it takes a requirement: it MUST eq(1)" unless ::Spectus::Requirement === requirement
      raise ::TypeError, "the to_s of the matcher must be a String" unless ::String === requirement.matcher.to_s

      location ||= caller_locations(1, 1).fetch(0)
      @expectations << Expectation.new(location: locate(location), requirement:)
      nil
    end

    private

    # A let named in an expectation is a mistake with a remedy.
    def method_missing(name, ...)
      return super unless @lets.key?(name)

      raise ::NameError.new("#{name} is a let, visible in the subject block and in other lets only", name)
    end

    def respond_to_missing?(_name, _include_private = false)
      false
    end

    # A child context, whose nodes follow this one's.
    def context(lets, challenges, chain, own = [], &)
      child = Dsl.new(lets, challenges, chain, own)
      child.instance_exec(&)
      @children.concat(child.nodes)
      nil
    end

    # A name a let can take: a Symbol that is not a method of the environment,
    # public or private, nor a public word of the language, so that nothing
    # is redefined in silence.
    def free!(name)
      raise ::ArgumentError, "the name of a let must be a Symbol" unless ::Symbol === name
      raise ::ArgumentError, "#{name} is a word of the specification language" if WORDS.include?(name)

      owner = [Environment, Dsl].find { |klass| klass.method_defined?(name) }
      owner ||= Environment if Environment.private_method_defined?(name)
      raise ::ArgumentError, "#{name} is already a method of #{owner.instance_method(name).owner}" if owner
    end

    # `file:line`, the file relative to the current directory when it is
    # under it.
    def locate(location)
      path = ::File.absolute_path(location.path).delete_prefix(::File.join(::Dir.pwd, ""))
      text("#{path}:#{location.lineno}")
    end

    # A text of a result, valid UTF-8 and frozen, as those of Spectus.
    def text(string)
      string.encode(::Encoding::UTF_8, invalid: :replace, undef: :replace).freeze
    end
  end
end
