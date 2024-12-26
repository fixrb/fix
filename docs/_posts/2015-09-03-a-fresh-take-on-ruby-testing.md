---
author: "Cyril Kato"
layout: "post"
title: "Fix 0.7: A Fresh Take on Ruby Testing"
date: "2015-09-03"
tags: [testing-frameworks rspec magic-tricks]
---
Today marks an exciting milestone in our journey as we announce the release of Fix 0.7! After months of careful development and [multiple iterations](https://speakerdeck.com/cyril/konbanha-tiao-jian-yabiheibiatesuto), we're proud to present a testing framework that brings simplicity and clarity back to Ruby testing.

## The Philosophy Behind Fix

Fix emerged from a simple observation: testing frameworks shouldn't be more complex than the code they're testing. Built on just 148 lines of code and powered by the [Spectus expectation library](https://github.com/fixrb/spectus), Fix takes a deliberately minimalist approach. We've intentionally omitted features like benchmarking and mocking to focus on what matters most: writing clear, maintainable specifications.

### Key Features

- **Pure Specification Documents**: Fix treats specs as living documents that remain logic-free and crystal clear
- **RFC 2119 Compliance**: Requirements are qualified using standardized terminology (MUST, SHOULD, MAY)
- **Version-Resistant**: Specifications remain stable across Fix versions, protecting against software erosion
- **No Magic**: We avoid monkey-patching and other Ruby "[magic tricks](https://blog.arkency.com/2013/06/are-we-abusing-at-exit/)" that can obscure behavior
- **Authentic Ruby Objects**: Work with pure, unmuted Ruby objects for unambiguous and structured specs

## Why Another Testing Framework?

After a decade of Ruby development, I found myself struggling to understand RSpec's source code. This raised a concerning question: if a testing framework is more complex than the code it tests, how confident can we be in our tests?

Let's look at a revealing example:

```ruby
class App
  def equal?(*)
    true
  end
end

require "rspec"

RSpec.describe App do
  it "is the answer to life, the universe and everything" do
    expect(described_class.new).to equal(42)
  end
end
```

Running this with RSpec:

```bash
$ rspec wat_spec.rb
.

Finished in 0.00146 seconds (files took 0.17203 seconds to load)
1 example, 0 failures
```

Surprisingly, RSpec tells us that `App.new` equals 42! While this specific issue could be resolved by [reversing actual and expected values](https://github.com/rspec/rspec-expectations/blob/995d1acd5161d94d28f6af9835b79c9d9e586307/lib/rspec/matchers/built_in/equal.rb#L40), it highlights potential risks in complex testing frameworks.

## Fix in Action

Let's see how Fix handles a real-world example. Consider this Duck class:

```ruby
# duck.rb
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

Here's how we specify its behavior with Fix:

```ruby
# duck_spec.rb
require_relative "duck"
require "fix"

@bird = Duck.new

Fix.describe @bird do
  on :swims do
    it { MUST eql "Swoosh..." }
  end

  on :speaks do
    it { MUST raise_exception NoMethodError }
  end

  on :sings do
    it { MAY eql "♪... ♫..." }
  end
end
```

Running the specification:

```bash
$ ruby duck_spec.rb
..I

1. Info: undefined method `sings' for #<Duck:0x007fb60383b740> (NoMethodError).

Ran 3 tests in 0.00038 seconds
100% compliant - 1 infos, 0 failures, 0 errors
```

Notice how Fix provides clear, unambiguous results while maintaining a simple and elegant syntax.

## Looking Forward

As we approach version 1.0.0, our focus remains on stability and refinement rather than adding new features. Fix is ready for production use, and we're excited to see how the Ruby community puts it to work.

### Get Involved

- Try Fix in your projects: `gem install fix`
- [Visit our GitHub repository](https://github.com/fixrb/fix)
- Share your feedback - we value all perspectives!

Whether you love it or see room for improvement, we want to hear from you. Your feedback will help shape the future of Fix.

Happy testing!
