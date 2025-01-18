# frozen_string_literal: true

require_relative "dsl"
require_relative "requirement/definition"

module Fix
  # A Spec represents a test specification that can be executed as a test suite.
  # It manages the lifecycle of specifications, including:
  # - Building and loading specifications from contexts
  # - Executing specifications in isolation using process forking
  # - Reporting test results
  # - Managing test execution flow and exit status
  #
  # @example Creating and running a simple specification
  #   spec = Fix::Spec.build(:Calculator) do
  #     on(:add, 2, 3) do
  #       it MUST eq 5
  #     end
  #   end
  #   spec.test { Calculator.new }
  #
  # @example Loading and running a registered specification
  #   spec = Fix::Spec.load(:Calculator)
  #   spec.match? { Calculator.new } #=> true
  #
  # @api private
  class Spec
    # Builds a new Spec from a specification block.
    #
    # This method:
    # 1. Creates a new DSL class for the specification
    # 2. Evaluates the specification block in this context
    # 3. Optionally registers the specification under a name
    # 4. Returns a Spec instance ready for testing
    #
    # @param name [Symbol, nil] Optional name to register the specification under
    # @yield Block containing the specification definition using Fix DSL
    # @return [Fix::Spec] A new specification ready for testing
    #
    # @example Building a named specification
    #   Fix::Spec.build(:Calculator) do
    #     on(:add, 2, 3) { it MUST eq 5 }
    #   end
    #
    # @example Building an anonymous specification
    #   Fix::Spec.build(nil) do
    #     it MUST be_positive
    #   end
    #
    # @api private
    def self.build(name, &block)
      raise Error::MissingSpecificationBlock unless block

      klass = ::Class.new(Dsl) do
        define_singleton_method(:challenges) do
          []
        end
      end

      Spec.const_set(name, klass) if name
      klass.class_eval(&block)
      new(klass)
    end

    # Loads a previously registered specification by name.
    #
    # @param name [Symbol] The name of the registered specification
    # @return [Fix::Spec] The loaded specification
    # @raise [NameError] If the specification name is not found
    #
    # @example Loading a registered specification
    #   Fix::Spec.load(:Calculator)  #=> #<Fix::Spec:...>
    #
    # @api private
    def self.load(name)
      klass = Spec.const_get(name)
      new(klass)
    end

    def initialize(klass)
      @definitions = collect_classes(klass).shuffle.flat_map do |spec_class|
        context = spec_class.new
        context.public_methods(false).map do |public_method|
          requirement, location = context.public_send(public_method)
          Requirement::Definition.new(context, requirement, location, *spec_class.challenges)
        end
      end
    end

    # Verifies if a subject matches all specifications without exiting.
    #
    # This method is useful for:
    # - Conditional testing where exit on failure is not desired
    # - Integration into larger test suites
    # - Programmatic test result handling
    #
    # @yield Block that returns the subject to test
    # @yieldreturn [Object] The subject to test against specifications
    # @return [Boolean] true if all tests pass, false otherwise
    # @raise [Error::MissingSubjectBlock] If no subject block is provided
    #
    # @example Basic matching
    #   spec.match? { Calculator.new }  #=> true
    #
    # @example Conditional testing
    #   if spec.match? { user_input }
    #     process_valid_input(user_input)
    #   else
    #     handle_invalid_input
    #   end
    #
    # @api public
    def match?(&subject)
      raise Error::MissingSubjectBlock unless subject

      @definitions.all? do |definition|
        definition.test(&subject).passed?
      end
    end

    # Executes the complete test suite against a subject.
    #
    # This method provides a comprehensive test run that:
    # - Executes all specifications in random order
    # - Runs each test in isolation via process forking
    # - Reports results for each specification
    # - Exits with appropriate status code
    #
    # @yield Block that returns the subject to test
    # @yieldreturn [Object] The subject to test against specifications
    # @return [Boolean] true if all tests pass
    # @raise [SystemExit] Exits with status 1 if any test fails
    # @raise [Error::MissingSubjectBlock] If no subject block is provided
    #
    # @example Basic test execution
    #   spec.test { Calculator.new }
    #
    # @example Testing with dependencies
    #   spec.test {
    #     calc = Calculator.new
    #     calc.precision = :high
    #     calc
    #   }
    #
    # @api public
    def test(&subject)
      raise Error::MissingSubjectBlock unless subject

      success = true

      @definitions.each do |definition|
        result = definition.test(&subject)
        success = false unless result.passed?
        report_result(definition.location, result)
      end

      success || exit_with_failure
    end

    private

    def report_result(location, result)
      puts "#{location} #{result.colored_string}"
    end

    def exit_with_failure
      ::Kernel.exit(false)
    end

    def collect_classes(klass)
      classes = [klass]

      subclasses = klass.constants.map { |const| klass.const_get(const) }
                        .select { |const| const.is_a?(::Class) && const < klass }

      subclasses.each do |subclass|
        classes.concat(collect_classes(subclass))
      end

      classes
    end
  end
end
