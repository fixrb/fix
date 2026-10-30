# frozen_string_literal: true

require "aw"
require "defi"

require_relative "dsl"
require_relative "result"

module Fix
  # The lib directories of fix and of the gems it runs, each found by a
  # method or a module its root file defines, not by the name of a file,
  # which another file could bear: their frames are left out of a backtrace
  # printed by {Spec#test}.
  LIBRARIES = ([
    ::Aw.method(:fork!).source_location,
    ::Object.const_source_location("Defi"),
    ::Object.const_source_location("Matchi"),
    ::Spectus.method(:must).source_location
  ].map { |location| "#{::File.dirname(location.fetch(0))}/" } << "#{::File.expand_path("..", __dir__)}/").freeze
  private_constant :LIBRARIES

  # A specification: its name and its contexts, built once by {Fix.spec} and
  # never changed. Tested against a subject with {#run} or {#test}, it is
  # also a matcher: {#match?} tests a value, as `it MUST fix(:Name)` does.
  #
  # @!attribute [r] name
  #   @return [Symbol, nil] the name, nil for an anonymous specification
  # @!attribute [r] nodes
  #   @return [Array<Fix::Node>] the contexts, each before its children
  #   @api private
  Spec = ::Data.define(:name, :nodes) do
    # Tests a subject against every expectation, each context in a child
    # process, and gives the results. The block builds the subject: it runs
    # once per expectation, where the lets live.
    #
    # @param fork [Boolean] whether each context runs in a child process;
    #   `false` for a debugger only
    # @yieldreturn [Object] the subject
    # @return [Array<Fix::Result>] in the order of the contexts, then of
    #   their expectations
    # @raise [ArgumentError] without a block
    # @raise [NotImplementedError] when this Ruby cannot fork
    # @raise [Aw::ChildError] when a child died or delivered no result
    # @raise [TypeError] when the `to_s` of a matcher is not a String; what a
    #   child raised outside an expectation is raised here again
    def run(fork: true, &subject)
      raise ::ArgumentError, "a block must be given" unless subject

      nodes.flat_map { |node| results(node, fork, subject) }
    end

    # Like {#run}, writing each result on the standard output as its
    # context ends, one line each, with the backtrace of an error below.
    #
    # @param fork [Boolean] as for {#run}
    # @yieldreturn [Object] the subject
    # @return [Boolean] whether every expectation is met
    # @raise (see #run)
    def test(fork: true, &subject) # rubocop:disable Naming/PredicateMethod
      raise ::ArgumentError, "a block must be given" unless subject

      nodes.map do |node|
        results(node, fork, subject).each { |result| $stdout.puts(lines(result)) }.all?(&:passed?)
      end.all?
    end

    # Tests a value, as a matcher does: the block is called once, and its
    # value is the subject of every expectation.
    #
    # @yieldreturn [Object] the value
    # @return [Boolean] whether every expectation is met
    # @raise (see #run)
    def match?
      raise ::ArgumentError, "a block must be given" unless block_given?

      value = yield
      run { value }.all?(&:passed?)
    end

    # @return [String] `fix NAME`, or `fix an anonymous specification`
    def to_s
      "fix #{name || "an anonymous specification"}"
    end

    alias_method :inspect, :to_s

    private

    # The results of a context, from a child process or not.
    def results(node, fork, subject)
      return [] if node.expectations.empty?

      work = -> { examine(node, subject) }
      spectus = fork ? ::Aw.fork!(&work) : work.call
      node.expectations.zip(spectus).map do |expectation, result|
        Result.new(location: expectation.location, chain: node.chain, result:)
      end
    end

    # The results of the expectations of a context, in the process that works
    # on them. A process the subject forked and let run on, instead of ending
    # it with exit!, is not that one: it leaves here without a word.
    def examine(node, subject)
      pid = ::Process.pid
      node.expectations.map do |expectation|
        result = judge(node, expectation, subject)
        ::Process.exit! unless ::Process.pid == pid

        result
      end
    end

    # One expectation, in a new environment: the subject is built, the
    # chain is sent, and the requirement judges what came out. A method of
    # the chain missing on its receiver makes a MAY an info, as a method
    # missing on the actual value does for Spectus, when the error that
    # came out is a NoMethodError by its class name: an exception of a
    # subclass, which Ruby does not raise for a missing method, stays an
    # error.
    def judge(node, expectation, subject)
      environment = Environment.new(node.lets)
      missing = false
      result = expectation.requirement.call do
        value, missing = actual(node, environment, subject)
        value.call
      end
      omission = missing && expectation.requirement.level.equal?(:MAY) && result.error_class == "NoMethodError"
      omission ? result.with(outcome: :info) : result
    end

    # The subject through the chain: a value, and whether the chain stopped
    # on a method missing on its receiver.
    def actual(node, environment, subject)
      object = environment.instance_exec(&subject)
      node.challenges.each do |challenge|
        value = challenge.to(object)
        return [value, missing?(value.object, object, challenge)] if value.raised?

        object = value.object
      end
      [::Defi::Value.new(object, false), false]
    end

    # Whether an exception is a NoMethodError for the method of the
    # challenge on the very object it was sent to, read as NameError and
    # BasicObject do, whatever the objects say. A NoMethodError built by
    # hand without a receiver raises ArgumentError when asked for it: it
    # names no object, so the method is not missing on one.
    def missing?(exception, object, challenge)
      return false unless ::NoMethodError === exception

      receiver = ::NameError.instance_method(:receiver).bind_call(exception)
      ::BasicObject.instance_method(:equal?).bind_call(receiver, object) &&
        challenge.name.equal?(::NameError.instance_method(:name).bind_call(exception))
    rescue ::ArgumentError
      false
    end

    # The line of a result, then the frames of an error that are not ours,
    # each on one line too.
    def lines(result)
      frames = result.outcome == :error ? (result.result.backtrace || []) : []
      frames = frames.reject { |frame| frame.start_with?(*LIBRARIES) }
      [result.to_s] + frames.map { |frame| "  #{frame.gsub(/\R/) { "\\n" }}" }
    end
  end
end
