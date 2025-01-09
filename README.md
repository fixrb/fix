# Fix Framework

[![Home](https://img.shields.io/badge/Home-fixrb.dev-00af8b)](https://fixrb.dev/)
[![Version](https://img.shields.io/github/v/tag/fixrb/fix?label=Version&logo=github)](https://github.com/fixrb/fix/tags)
[![Yard documentation](https://img.shields.io/badge/Yard-documentation-blue.svg?logo=github)](https://rubydoc.info/github/fixrb/fix/main)
[![License](https://img.shields.io/github/license/fixrb/fix?label=License&logo=github)](https://github.com/fixrb/fix/raw/main/LICENSE.md)

## Introduction

Fix is a modern Ruby testing framework that emphasizes clear separation between specifications and examples. Unlike traditional testing frameworks, Fix focuses on creating pure specification documents that define expected behaviors without mixing in implementation details.

## Installation

### Prerequisites

- Ruby >= 3.1.0

### Setup

Add to your Gemfile:

```ruby
gem "fix"
```

Then execute:

```sh
bundle install
```

Or install it yourself:

```sh
gem install fix
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

The implementation might look like this:

```ruby
class User
  attr_reader :role, :password_hash

  def initialize(role:)
    @role = role
    @password_hash = nil
  end

  def admin?
    role == "admin"
  end

  def can_access?(resource)
    return true if admin?
    false
  end

  def full_name
    "#{@first_name} #{@last_name}"
  end

  def update_password(new_password)
    @password_hash = Digest::SHA256.hexdigest(new_password)
    true
  end
end
```

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

<details>
<summary><strong>Basic Comparison Matchers</strong></summary>

- `eq(expected)` - Tests equality using `eql?`
  ```ruby
  it MUST eq(42)                   # Passes if value.eql?(42)
  it MUST eq("hello")              # Passes if value.eql?("hello")
  ```
- `eql(expected)` - Alias for eq
- `be(expected)` - Tests object identity using `equal?`
  ```ruby
  string = "test"
  it MUST be(string)               # Passes only if it's exactly the same object
  ```
- `equal(expected)` - Alias for be
</details>

<details>
<summary><strong>Type Checking Matchers</strong></summary>

- `be_an_instance_of(class)` - Verifies exact class match
  ```ruby
  it MUST be_an_instance_of(Array) # Passes if value.instance_of?(Array)
  it MUST be_an_instance_of(User)  # Passes if value.instance_of?(User)
  ```
- `be_a_kind_of(class)` - Checks class inheritance and module inclusion
  ```ruby
  it MUST be_a_kind_of(Enumerable) # Passes if value.kind_of?(Enumerable)
  it MUST be_a_kind_of(Animal)     # Passes if value inherits from Animal
  ```
</details>

<details>
<summary><strong>Change Testing Matchers</strong></summary>

- `change(object, method)` - Base matcher for state changes
  - `.by(n)` - Expects exact change by n
    ```ruby
    it MUST change(user, :points).by(5)          # Exactly +5 points
    ```
  - `.by_at_least(n)` - Expects minimum change by n
    ```ruby
    it MUST change(counter, :value).by_at_least(10)  # At least +10
    ```
  - `.by_at_most(n)` - Expects maximum change by n
    ```ruby
    it MUST change(account, :balance).by_at_most(100) # No more than +100
    ```
  - `.from(old).to(new)` - Expects change from old to new value
    ```ruby
    it MUST change(user, :status).from("pending").to("active")
    ```
  - `.to(new)` - Expects change to new value
    ```ruby
    it MUST change(post, :title).to("Updated")
    ```
</details>

<details>
<summary><strong>Numeric Matchers</strong></summary>

- `be_within(delta).of(value)` - Tests if a value is within ±delta of expected value
  ```ruby
  it MUST be_within(0.1).of(3.14)  # Passes if value is between 3.04 and 3.24
  it MUST be_within(5).of(100)     # Passes if value is between 95 and 105
  ```
</details>

<details>
<summary><strong>Pattern Matchers</strong></summary>

- `match(regex)` - Tests string against regular expression pattern
  ```ruby
  it MUST match(/^\d{3}-\d{2}-\d{4}$/)  # SSN format
  it MUST match(/^[A-Z][a-z]+$/)        # Capitalized word
  ```
- `satisfy { |value| ... }` - Custom matching with block
  ```ruby
  it MUST satisfy { |num| num.even? && num > 0 }
  it MUST satisfy { |user| user.valid? && user.active? }
  ```
</details>

<details>
<summary><strong>Exception Matchers</strong></summary>

- `raise_exception(class)` - Tests if code raises specified exception
  ```ruby
  it MUST raise_exception(ArgumentError)
  it MUST raise_exception(CustomError, "specific message")
  ```
</details>

<details>
<summary><strong>State Matchers</strong></summary>

- `be_true` - Tests for true
  ```ruby
  it MUST be_true          # Only passes for true, not truthy values
  ```
- `be_false` - Tests for false
  ```ruby
  it MUST be_false         # Only passes for false, not falsey values
  ```
- `be_nil` - Tests for nil
  ```ruby
  it MUST be_nil           # Passes only for nil
  ```
</details>

<details>
<summary><strong>Specification Matchers</strong></summary>

- `fix(name = nil) { ... }` - Tests against shared specifications
  ```ruby
  # Define a shared specification for any serializable object
  Fix :Serializable do
    it MUST respond_to(:to_json)
    it MUST respond_to(:to_yaml)

    on :to_json do
      it MUST be_a_kind_of(String)
      it MUST match(/^\{.+\}$/)
    end
  end

  # Use the shared spec in different contexts
  Fix :User do
    it MUST fix(:Serializable)  # User must be serializable

    # Add User-specific requirements
    it MUST have_key(:email)
  end

  Fix :Product do
    it MUST fix(:Serializable)  # Product must also be serializable

    # Add Product-specific requirements
    it MUST have_key(:price)
  end

  # Compose with multiple shared specifications
  Fix :AdminUser do
    # Reuse both user and permission specifications
    it MUST fix(:User)
    it MUST fix(:HasPermissions)

    # Add admin-specific behavior
    with role: :admin do
      it MUST be_admin
    end
  end

  # Use inline for more specific shared behaviors
  Fix :ApiResponse do
    # Shared error response specification
    let(:error_spec) do
      fix do
        it MUST have_key(:error)
        it MUST have_key(:code)

        on :code do
          it MUST be_a_kind_of(Integer)
        end
      end
    end

    # Test different response types
    with status: :error do
      it MUST satisfy(error_spec)
    end

    with status: :validation_error do
      it MUST satisfy(error_spec)
      it MUST have_key(:fields)  # Additional requirement
    end
  end
  ```
</details>

### Complete Example

Here's an example using various matchers together:

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

  with string_input: "123" do
    on :parse do
      it MUST be_a_kind_of Numeric
      it MUST satisfy { |n| n > 0 }
    end
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
