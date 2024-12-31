# Fix Framework

[![Home](https://img.shields.io/badge/Home-fixrb.dev-00af8b)](https://fixrb.dev/)
[![Version](https://img.shields.io/github/v/tag/fixrb/fix?label=Version&logo=github)](https://github.com/fixrb/fix/tags)
[![Yard documentation](https://img.shields.io/badge/Yard-documentation-blue.svg?logo=github)](https://rubydoc.info/github/fixrb/fix/main)
[![License](https://img.shields.io/github/license/fixrb/fix?label=License&logo=github)](https://github.com/fixrb/fix/raw/main/LICENSE.md)

## Introduction

Fix is a modern Ruby testing framework that emphasizes clear separation between specifications and examples. Unlike traditional testing frameworks, Fix focuses on creating pure specification documents that define expected behaviors without mixing in implementation details.

## Installation

Add to your Gemfile:

```ruby
gem "fix", ">= 1.0.0.beta12"
```

Then execute:

```sh
bundle install
```

Or install it yourself:

```sh
gem install fix --pre
```

## Core Principles

- **Specifications vs Examples**: Fix makes a clear distinction between specifications (what is expected) and examples (how it's demonstrated). This separation leads to cleaner, more maintainable test suites.

- **Logic-Free Specifications**: Your specification documents remain pure and focused on defining behaviors, without getting cluttered by implementation logic.

- **Rich Semantic Language**: Following RFC 2119 conventions, Fix uses precise language with keywords like MUST, SHOULD, and MAY to clearly define different requirement levels in specifications.

- **Fast Individual Testing**: Tests execute quickly and independently, providing rapid feedback on specification compliance.

## Framework Features

### Property Definition with `let`

Define reusable properties across your specifications:

```ruby
Fix do
  let(:name) { "Bob" }
  let(:age) { 42 }

  it MUST eq name
end
```

### Context Creation with `with`

Test behavior under different conditions:

```ruby
Fix do
  with name: "Alice", role: "admin" do
    it MUST be_allowed
  end

  with name: "Bob", role: "guest" do
    it MUST_NOT be_allowed
  end
end
```

### Method Testing with `on`

Test how objects respond to specific messages:

```ruby
Fix do
  on :upcase do
    it MUST eq "HELLO"
  end

  on :+, 2 do
    it MUST eq 42
  end
end
```

### Requirement Levels

Fix provides three levels of requirements, each with clear semantic meaning:

- **MUST/MUST_NOT**: Absolute requirements or prohibitions
- **SHOULD/SHOULD_NOT**: Recommended practices with valid exceptions
- **MAY**: Optional features

```ruby
Fix do
  it MUST be_valid           # Required
  it SHOULD be_optimized     # Recommended
  it MAY include_metadata    # Optional
end
```

## Quick Start

Create your first test file:

```ruby
# first_test.rb
require "fix"

Fix :HelloWorld do
  it MUST eq "Hello, World!"
end

Fix[:HelloWorld].test { "Hello, World!" }
```

Run it:

```sh
ruby first_test.rb
```

## Real-World Examples

Fix is designed to work with real-world applications of any complexity. Here are some examples demonstrating how Fix can be used in different scenarios:

### Example 1: User Account Management

Here's a comprehensive example showing how to specify a user account system:

```ruby
Fix :UserAccount do
  # Define reusable properties
  let(:admin) { User.new(role: "admin") }
  let(:guest) { User.new(role: "guest") }

  # Test basic instance properties
  it MUST be_an_instance_of User

  # Test with different contexts
  with role: "admin" do
    it MUST be_admin

    on :can_access?, "settings" do
      it MUST be_true
    end
  end

  with role: "guest" do
    it MUST_NOT be_admin

    on :can_access?, "settings" do
      it MUST be_false
    end
  end

  # Test specific methods
  on :full_name do
    with first_name: "John", last_name: "Doe" do
      it MUST eq "John Doe"
    end
  end

  on :update_password, "new_password" do
    it MUST change(admin, :password_hash)
    it MUST be_true  # Return value check
  end
end
```

This example demonstrates:
- Using `let` to define test fixtures
- Context-specific testing with `with`
- Method behavior testing with `on`
- Different requirement levels with `MUST`/`MUST_NOT`
- Testing state changes with the `change` matcher
- Nested contexts for complex scenarios

### Example 2: Duck Specification

Here's how Fix can be used to specify a Duck class:

```ruby
Fix :Duck do
  it SHOULD be_an_instance_of :Duck

  on :swims do
    it MUST be_an_instance_of :String
    it MUST eql "Swoosh..."
  end

  on :speaks do
    it MUST raise_exception NoMethodError
  end

  on :sings do
    it MAY eql "♪... ♫..."
  end
end
```

The implementation:

```ruby
class Duck
  def walks
    "Klop klop!"
  end

  def swims
    "Swoosh..."
  end

  def quacks
    puts "Quaaaaaack!"
  end
end
```

Running the test:

```ruby
Fix[:Duck].test { Duck.new }
```

## Available Matchers

Fix includes a comprehensive set of matchers through its integration with the [Matchi library](https://github.com/fixrb/matchi):

### Basic Comparison Matchers
- `eq(expected)` - Tests equality using `eql?`
- `be(expected)` - Tests object identity using `equal?`

### Type Checking Matchers
- `be_an_instance_of(class)` - Verifies exact class match
- `be_a_kind_of(class)` - Checks class inheritance and module inclusion

### Change Testing Matchers
- `change(object, method)` - Base matcher for state changes
  - `.by(n)` - Expects exact change by n
  - `.by_at_least(n)` - Expects minimum change by n
  - `.by_at_most(n)` - Expects maximum change by n
  - `.from(old).to(new)` - Expects change from old to new value
  - `.to(new)` - Expects change to new value

### Numeric Matchers
- `be_within(delta).of(value)` - Tests if a value is within ±delta of expected value

### Pattern Matchers
- `match(regex)` - Tests string against regular expression pattern
- `satisfy { |value| ... }` - Custom matching with block

### State Matchers
- `be_true` - Tests for true
- `be_false` - Tests for false
- `be_nil` - Tests for nil

### Exception Matchers
- `raise_exception(class)` - Tests if code raises specified exception

### Dynamic Predicate Matchers
- `be_*` - Dynamically matches `object.*?` methods (e.g., `be_empty` calls `empty?`)
- `have_*` - Dynamically matches `object.has_*?` methods (e.g., `have_key` calls `has_key?`)

Example usage:

```ruby
Fix :Calculator do
  it MUST be_an_instance_of Calculator

  on :add, 2, 3 do
    it MUST eq 5
    it MUST be_within(0.001).of(5.0)
  end

  on :divide, 1, 0 do
    it MUST raise_exception ZeroDivisionError
  end

  with numbers: [1, 2, 3] do
    it MUST_NOT be_empty
    it MUST satisfy { |result| result.all? { |n| n.positive? } }
  end
end
```

## Why Choose Fix?

Fix brings several unique advantages to Ruby testing that set it apart from traditional testing frameworks:

- **Clear Separation of Concerns**: Keep your specifications clean and your examples separate
- **Semantic Precision**: Express requirements with different levels of necessity
- **Fast Execution**: Get quick feedback on specification compliance
- **Pure Specifications**: Write specification documents that focus on behavior, not implementation
- **Rich Matcher Library**: Comprehensive set of matchers for different testing needs
- **Modern Ruby**: Takes advantage of modern Ruby features and practices

## Get Started

Ready to write better specifications? Visit our [GitHub repository](https://github.com/fixrb/fix) to start using Fix in your Ruby projects.

## Community & Resources

- [Blog](https://fixrb.dev/) - Related articles
- [Bluesky](https://bsky.app/profile/fixrb.dev) - Latest updates and discussions
- [Documentation](https://www.rubydoc.info/gems/fix) - Comprehensive guides and API reference
- [Source Code](https://github.com/fixrb/fix) - Contribute and report issues
- [asciinema](https://asciinema.org/~fix) - Watch practical examples in action

## Versioning

__Fix__ follows [Semantic Versioning 2.0](https://semver.org/).

## License

The [gem](https://rubygems.org/gems/fix) is available as open source under the terms of the [MIT License](https://github.com/fixrb/fix/raw/main/LICENSE.md).

## Sponsors

This project is sponsored by [Sashité](https://sashite.com/)
