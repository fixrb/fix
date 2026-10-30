# frozen_string_literal: true

require_relative File.join("support", "coverage")
require_relative File.join("..", "lib", "fix")

# Each word builds the matcher of Matchi, described as Matchi does, inside
# a specification.
words = Fix.spec do
  it MUST eq 42
  it MUST be :a
  it MUST be_within(0.5).of(3)
  it MUST match(/a/)
  it MUST raise_exception ZeroDivisionError
  it MUST raise_exception ZeroDivisionError, /by 0/
  it MUST be_true
  it MUST be_false
  it MUST be_nil
  it MUST be_an_instance_of Integer
  it MUST be_a_kind_of Comparable
  it MUST change(+"", :length).by(1)
  it MUST change(+"", :length).from(0).to(1)
  it MUST satisfy(&:positive?)
  it SHOULD eq 1
  it SHOULD_NOT eq 1
  it MUST_NOT eq 1
  it MAY eq 1
end
matchers = words.nodes.first.expectations.map { |expectation| expectation.requirement.matcher }
raise unless matchers.map(&:class) == [Matchi::Eq, Matchi::Be, Matchi::BeWithin::Of, Matchi::Match,
                                       Matchi::RaiseException, Matchi::RaiseException, Matchi::Be, Matchi::Be,
                                       Matchi::Be, Matchi::BeAnInstanceOf, Matchi::BeAKindOf, Matchi::Change::Delta,
                                       Matchi::Change::FromTo, Matchi::Satisfy, Matchi::Eq, Matchi::Eq, Matchi::Eq,
                                       Matchi::Eq]
raise unless matchers.map(&:to_s) == ["eq 42", "be :a", "be within 0.5 of 3", "match /a/",
                                      "raise exception ZeroDivisionError",
                                      "raise exception ZeroDivisionError with message /by 0/",
                                      "be true", "be false", "be nil", "be an instance of Integer",
                                      "be a kind of Comparable", "change by 1",
                                      "change from 0 to 1", "satisfy &block", "eq 1", "eq 1", "eq 1",
                                      "eq 1"]
levels = words.nodes.first.expectations.map do |expectation|
  [expectation.requirement.level, expectation.requirement.negate]
end
raise unless levels.last(4) == [[:SHOULD, false], [:SHOULD, true], [:MUST, true], [:MAY, false]]
raise unless levels.first == [:MUST, false]

# What a matcher refuses at construction is refused when the file loads.
error = begin
  Fix.spec { it MUST raise_exception String }
rescue ArgumentError => e
  e
end
raise unless error.message.start_with?("expected must inherit from Exception")
error = begin
  Fix.spec { it MUST match "a" }
rescue ArgumentError => e
  e
end
raise unless error.instance_of?(ArgumentError)
