---
layout: post
title: "From RSpec to Fix: A Journey Towards Simpler Testing"
description: "Discover how Fix brings simplicity and clarity to Ruby testing with its minimalist approach and intuitive syntax, comparing it with traditional frameworks like RSpec."
date: 2015-09-06 12:00:00 +0100
author: Cyril Kato
categories:
  - framework
  - comparison
tags:
  - fix
  - ruby
  - rspec
  - testing
  - simplicity
---
## The Quest for Simplicity

One of the most striking differences between Fix and traditional testing frameworks like RSpec lies in their complexity. Let's look at some numbers that tell an interesting story:

### RSpec's Components (version 3.3)

- [rspec](https://github.com/rspec/rspec/releases/tag/v3.3.0) gem (7 LOC) with runtime dependencies:
  - [rspec-core](https://github.com/rspec/rspec-core/releases/tag/v3.3.2): 6,689 LOC
  - [rspec-expectations](https://github.com/rspec/rspec-expectations/releases/tag/v3.3.1): 3,697 LOC
  - [rspec-mocks](https://github.com/rspec/rspec-mocks/releases/tag/v3.3.2): 3,963 LOC
  - [rspec-support](https://github.com/rspec/rspec-support/releases/tag/v3.3.0): 1,509 LOC
  - [diff-lcs](https://github.com/halostatue/diff-lcs/releases/tag/v1.2.5): 1,264 LOC

**Total: 17,129 lines of code**

### Fix's Components (version 0.7)

- [fix](https://github.com/fixrb/fix/releases/tag/v0.7.0) gem (148 LOC) with runtime dependencies:
  - [spectus](https://github.com/fixrb/spectus/releases/tag/v2.3.1): 289 LOC
  - [matchi](https://github.com/fixrb/matchi/releases/tag/v0.0.9): 73 LOC

**Total: 510 lines of code**

The core philosophy is simple: a testing framework shouldn't be more complex than the code it tests. This dramatic difference in code size (16,619 lines of code) reflects Fix's commitment to minimalism and clarity.

## A Real-World Comparison

Let's look at a real-world example that demonstrates the key differences in approach. Consider this Monster class:

```ruby
class Monster
  def self.get
    {
      boo: {
        name: "Boo",
        life: 123,
        mana: 42
      },
      hasu: {
        name: "Hasu",
        life: 88,
        mana: 40
      }
    }
  end

  def get(id)
    self.class.get.fetch(id)
  end
end
```

### RSpec's Layered Approach

```ruby
require_relative "monster"
require "rspec/autorun"

RSpec.describe Monster do
  describe ".get" do
    subject(:monsters) { described_class.get }

    describe "#keys" do
      it { expect(monsters.keys).to eql %i(boo hasu) }
    end
  end

  describe ".new" do
    subject(:described_instance) { described_class.new }

    describe "#get" do
      subject(:monster) { described_instance.get(name) }

      context "with Boo monster" do
        let(:name) { :boo }
        it { expect(monster).to eql({ name: "Boo", life: 123, mana: 42 }) }
      end

      context "with Boom monster" do
        let(:name) { :boom }
        it { expect { monster }.to raise_exception KeyError }
      end
    end
  end
end
```

### Fix's Direct Style

```ruby
require_relative "monster"
require "fix"

Fix.describe Monster do
  on :get do
    on :keys do
      it { MUST eql %i(boo hasu) }
    end
  end

  on :new do
    on :get, :boo do
      it { MUST eql({ name: "Boo", life: 123, mana: 42 }) }
    end

    on :get, :boom do
      it { MUST raise_exception KeyError }
    end
  end
end
```

## Key Differentiators

1. **Method Chaining**: Fix allows describing methods with one expression, whether for class or instance methods. This leads to more concise and readable code.

2. **Single Source of Truth**: All specifications are derived from the described front object populated at the root. There's no need for explicit or implicit subjects - there's just one read-only dynamic subject deduced from the front object and described methods.

3. **Consistent Syntax**: Fix maintains the same syntax regardless of what's being tested. Whether you're checking a value, expecting an error, or verifying a state change, the syntax remains uniform and predictable.

## Clarity in Practice

Fix encourages a more direct and less ceremonial approach to testing. Compare how both frameworks handle error checking:

RSpec:
```ruby
expect { problematic_call }.to raise_exception(ErrorType)
```

Fix:
```ruby
it { MUST raise_exception ErrorType }
```

Or value comparison:

RSpec:
```ruby
expect(value).to eq(expected)
```

Fix:
```ruby
it { MUST eql expected }
```

This consistency helps reduce cognitive load and makes tests easier to write and understand.

## Conclusion

Fix represents a fresh approach to Ruby testing that prioritizes simplicity and clarity. By reducing complexity and maintaining a consistent syntax, it helps developers focus on what matters: writing clear, maintainable tests that effectively verify their code's behavior.

Want to try Fix for yourself? Get started with:

```sh
gem install fix
```

Visit our [documentation](https://rubydoc.info/gems/fix) to learn more about how Fix can improve your testing workflow.
