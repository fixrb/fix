# Fix

[![Home](https://img.shields.io/badge/Home-fixrb.dev-00af8b)](https://fixrb.dev/)
[![Version](https://img.shields.io/github/v/tag/fixrb/fix?label=Version&logo=github)](https://github.com/fixrb/fix/tags)
[![Yard documentation](https://img.shields.io/badge/Yard-documentation-blue.svg?logo=github)](https://rubydoc.info/github/fixrb/fix/main)
[![Ruby](https://github.com/fixrb/fix/workflows/Ruby/badge.svg?branch=main)](https://github.com/fixrb/fix/actions?query=workflow%3Aruby+branch%3Amain)
[![RuboCop](https://github.com/fixrb/fix/workflows/RuboCop/badge.svg?branch=main)](https://github.com/fixrb/fix/actions?query=workflow%3Arubocop+branch%3Amain)
[![License](https://img.shields.io/github/license/fixrb/fix?label=License&logo=github)](https://github.com/fixrb/fix/raw/main/LICENSE.md)

![Secure specing framework for Ruby](https://fixrb.dev/fix.webp "Fix")

## Project Goals

- **Distinguish Specifications from Examples**: Clear separation between what is expected (specifications) and how it's demonstrated (examples).
- **Logic-Free Specification Documents**: Create specifications that are straightforward and free of complex logic, focusing purely on defining expected behaviors.
- **Nuanced Semantic Language in Specifications**: Utilize a rich, nuanced semantic language, similar to that in RFC 2119, employing keywords like MUST, SHOULD, and MAY to define different levels of requirement in specifications.
- **Fast and Individual Test Execution**: Enable quick execution of tests on an individual basis, providing immediate feedback on compliance with specifications.

## Installation

Add to your Gemfile:

```ruby
gem "fix", ">= 1.0.0.beta10"
```

Then execute:

```sh
bundle install
```

Or install it yourself:

```sh
gem install fix --pre
```

## Getting Started

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

This simple example introduces the basic concepts:

- `Fix` creates a new specification
- `it MUST` defines a required expectation
- `eq` is a matcher that checks for equality
- `test { }` runs the test with the actual value

See the Duck example below for a more complete usage.

## DSL Methods

Fix provides a Domain Specific Language (DSL) to write clear and expressive specifications. Here's a complete overview of all available DSL methods:

### `let`

Defines a user-defined property that can be reused across specifications:

```ruby
Fix do
  let(:name) { "Bob" }
  let(:age) { 42 }

  it MUST eq name       # References the name property

  on :grow do
    it MUST eq age + 1  # Properties can be used in calculations
  end
end
```

### `with`

Creates a context with specific properties, allowing you to test behavior under different conditions:

```ruby
Fix do
  # Single property context
  with name: "Alice" do
    it MUST eq "Alice"
  end

  # Multiple properties
  with name: "Bob", age: 42 do
    it MUST include "Bob"
    it SHOULD be_positive
  end

  # Nested contexts
  with user: "admin" do
    with permission: "write" do
      it MUST be_allowed
    end
  end
end
```

### `on`

Defines an example group around a method call, testing how an object responds to specific messages:

```ruby
Fix do
  # Simple method call
  on :upcase do
    it MUST eq "HELLO"
  end

  # Method with arguments
  on :+, 2 do
    it MUST eq 42
  end

  # Method with keyword arguments
  on :resize, width: 100, height: 200 do
    it MUST eq [100, 200]
  end

  # Method chain testing
  on :split, " " do
    on :first do
      it MUST eq "Hello"
    end
  end
end
```

### `it`

Defines a concrete specification with a requirement level and matcher:

```ruby
Fix do
  # Required specifications
  it MUST eq 42
  it MUST_NOT be_nil

  # Recommended specifications
  it SHOULD be_positive
  it SHOULD_NOT be_empty

  # Optional specifications
  it MAY start_with "Hello"

  # Multiple specifications in same context
  on :calculate do
    it MUST be_an_instance_of Numeric  # Type check
    it MUST be_positive               # Value check
    it SHOULD be_within(0.01).of(42)  # Range check
  end
end
```

### Complete Example

Here's how these DSL methods work together in a real specification:

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

Each DSL method serves a specific purpose in creating clear, maintainable specifications:
- `let` for defining reusable values and setup
- `with` for creating specific test contexts
- `on` for testing method behavior
- `it` for defining expectations

Together, they allow you to write specifications that are both readable and comprehensive.

## Duck example

Specifications for a `Duck` class:

```ruby
# examples/duck/fix.rb

require "fix"

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

Implementing the `Duck` class:

```ruby
# examples/duck/app.rb

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
# examples/duck/test.rb

require_relative "app"
require_relative "fix"

Fix[:Duck].test { Duck.new }
```

Execute:

```sh
ruby examples/duck/test.rb
```

Expected output:

```txt
examples/duck/fix.rb:22 Success: expected to eq "Hi, my name is Donald!".
examples/duck/fix.rb:27 Success: expected "Swoosh..." to be an instance of String.
examples/duck/fix.rb:46 NoMethodError: undefined method `sings' for <Bob>:Duck.
examples/duck/fix.rb:31 Success: expected to be 9.
examples/duck/fix.rb:13 Success: expected to eq "Hi, my name is Picsou!".
examples/duck/fix.rb:42 Success: undefined method `speaks' for <Bob>:Duck.
examples/duck/fix.rb:8 Success: expected <Bob> to be an instance of Duck.
Quaaaaaack!
examples/duck/fix.rb:50 Success: expected to be nil.
examples/duck/fix.rb:28 Success: expected to eq "Swoosh...".
examples/duck/fix.rb:37 Success: expected to be 10.
examples/duck/fix.rb:18 Success: expected to eq "Hi, my name is Picsou!".
```

## Contact

- [Home page](https://fixrb.dev/)
- [Source code](https://github.com/fixrb/fix)
- [API Documentation](https://rubydoc.info/gems/fix)
- [Bluesky](https://bsky.app/profile/fixrb.dev)

## Versioning

__Fix__ follows [Semantic Versioning 2.0](https://semver.org/).

## License

The [gem](https://rubygems.org/gems/fix) is available as open source under the terms of the [MIT License](https://github.com/fixrb/fix/raw/main/LICENSE.md).

---

<p>
  This project is sponsored by:<br />
  <a href="https://sashite.com/"><img
    src="https://github.com/fixrb/fix/raw/main/img/sashite.png"
    alt="Sashité" /></a>
</p>
