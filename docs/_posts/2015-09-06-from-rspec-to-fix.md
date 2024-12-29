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

## Comparing Approaches: A Real-World Example

Let's examine how both frameworks handle a real-world testing scenario. Consider this Monster class:

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

### Traditional RSpec Approach

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

### The Fix Way

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

As we can see, the spec is shorter and easier to read, with a "DRY" approach. Fix allows describing methods with one expression, whether it concerns a class method's name or an instance method's name.

Additionally, all specifications are derived from the described front object that is populated at the root. Unlike in RSpec, there is no concept of implicit or explicit subjects - there is just one read-only dynamic subject which is deduced from the front object and the described methods.

Finally, while an RSpec expectation sometimes needs a parameter to handle [equivalence matcher](http://www.rubydoc.info/github/rspec/rspec-expectations/RSpec%2FMatchers%3Aeql), sometimes a block to handle [expect error matcher](http://www.rubydoc.info/github/rspec/rspec-expectations/RSpec%2FMatchers%3Araise_error), Fix's expectations are always written the same way, regardless of the responsibility and structure of matchers.

This article has presented some key differences in syntax between these two frameworks. I hope you will enjoy the new test interface proposed by Fix.

Want to try Fix for yourself? Get started with:

```sh
gem install fix
```

Visit our [documentation](https://fixrb.dev) to learn more about how Fix can improve your testing workflow.
