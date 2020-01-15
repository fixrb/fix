# frozen_string_literal: true

require 'aw'
require 'defi'

module Fix
  # Wraps the target of challenge.
  class Context
    RESERVED_KEYWORDS = %i[
      alias
      and
      begin
      break
      case
      catch
      class
      def
      defined?
      do
      else
      elsif
      end
      ensure
      fail
      false
      for
      if
      in
      module
      next
      nil
      not
      or
      raise
      redo
      rescue
      retry
      return
      self
      super
      then
      throw
      true
      undef
      unless
      until
      when
      while
      yield
    ].freeze

    attr_reader :callable

    def initialize(subject, challenge, before_hooks_counter = 0, *hooks, **lets)
      @subject      = subject
      @callable     = challenge.to(subject)
      @before_hooks = hooks[0, before_hooks_counter]
      @after_hooks  = hooks[before_hooks_counter..-1]
      @lets         = lets
    end

    def before(&block)
      @before_hooks << block
    end

    def after(&block)
      @after_hooks << block
    end

    def let(name, &block)
      raise ::TypeError, "expected a Symbol, got #{name.class}" unless name.is_a?(::Symbol)
      raise ::NameError, "wrong method name `#{name}'" unless name.match(/\A[a-z][a-z0-9_]+[?!]?\z/)
      raise ::NameError, "reserved keyword name `#{name}'" if RESERVED_KEYWORDS.include?(name)
      raise ::NameError, "reserved method name `#{name}'" if respond_to?(name, true) && !@lets.key?(name)

      @lets.update(name => block.call)
    rescue ::SystemExit => e
      raise SuspiciousSuccessError, "attempt `#{name}' to bypass the tests" if e.success?
      raise e
    end

    def let!(name, &block)
      raise ::TypeError, "expected a Symbol, got #{name.class}" unless name.is_a?(::Symbol)
      raise ::NameError, "wrong method name `#{name}'" unless name.match(/\A[a-z][a-z0-9_]+[?!]?\z/)
      raise ::NameError, "reserved keyword name `#{name}'" if RESERVED_KEYWORDS.include?(name)
      raise ::NameError, "reserved method name `#{name}'" if respond_to?(name, true) && !@lets.key?(name)

      @lets.update(name => ::Aw.fork! { block.call })
    rescue ::SystemExit => e
      raise SuspiciousSuccessError, "attempt `#{name}' to bypass the tests" if e.success?
      raise e
    end

    # Verify the expectation.
    #
    # @param block [Proc] A spec to compare against the computed actual value.
    #
    # @return [::Spectus::Result::Pass, ::Spectus::Result::Fail] Pass or fail.
    def it(_message = nil, &block)
      print "#{block.source_location.join(':')}: "
      i = It.new(callable, **@lets)
      @before_hooks.each { |hook| i.instance_eval(&hook) }
      result = i.instance_eval(&block)
      puts result.colored_string
    rescue ::Spectus::Result::Fail => result
      abort result.colored_string
    ensure
      @after_hooks.each { |hook| i.instance_eval(&hook) }
      raise ExpectationResultNotFoundError, result.class.inspect unless result.is_a?(::Spectus::Result::Common)
    end

    def on(name, *args, **options, &block)
      if callable.raised?
        actual    = callable
        challenge = ::Defi.send(:call)
      else
        actual    = callable.object
        challenge = ::Defi.send(name, *args, **options)
      end

      o = Context.new(actual, challenge, @before_hooks.length, *@before_hooks + @after_hooks, **@lets)
      o.instance_eval(&block)
    end

    def with(_message = nil, **new_lets, &block)
      actual    = callable.object
      challenge = ::Defi.send(:itself)

      c = Context.new(actual, challenge, @before_hooks.length, *@before_hooks + @after_hooks, **@lets.merge(new_lets))
      c.instance_eval(&block)
    end

    private

    def method_missing(name, *args, &block)
      @lets.fetch(name) { super }
    end

    def respond_to_missing?(name, include_private = false)
      @lets.key?(name) || super
    end
  end
end

require_relative 'it'
require_relative 'expectation_result_not_found_error'
require_relative 'suspicious_success_error'
