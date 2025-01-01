---
layout: home
title: "Fix: Happy Path to Ruby Testing"
---

## Modern Ruby Testing Framework

Fix is a modern Ruby testing framework that emphasizes clear separation between specifications and examples. Unlike traditional testing frameworks, Fix focuses on creating pure specification documents that define expected behaviors without mixing in implementation details.

### Getting Started

Add to your Gemfile:

```ruby
gem "fix"
```

Or install it yourself:

```sh
gem install fix
```

### Key Features

- **Pure Specifications**: Write specification documents that focus solely on defining behaviors
- **Semantic Precision**: Use MUST, SHOULD, and MAY to clearly define requirement levels
- **Clear Separation**: Keep specifications and implementations separate for better maintainability
- **Fast Execution**: Run tests quickly and independently
- **Rich Matcher Library**: Comprehensive set of matchers for different testing needs

### Quick Example

```ruby
# Define your specification
Fix :Calculator do
  on(:add, 2, 3) do
    it MUST eq 5
  end
end

# Test your implementation
Fix[:Calculator].test { Calculator }
```

Discover more about Fix in our [documentation](https://rubydoc.info/gems/fix) or check our [source code](https://github.com/fixrb/fix).
