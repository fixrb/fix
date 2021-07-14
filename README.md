# Fix

[![Home](https://img.shields.io/badge/Home-fixrb.dev-00af8b)](https://fixrb.dev/)
[![Version](https://img.shields.io/github/v/tag/fixrb/fix?label=Version&logo=github)](https://github.com/fixrb/fix/releases)
[![Yard documentation](https://img.shields.io/badge/Yard-documentation-blue.svg?logo=github)](https://rubydoc.info/github/fixrb/fix/main)
[![CI](https://github.com/fixrb/fix/workflows/CI/badge.svg?branch=main)](https://github.com/fixrb/fix/actions?query=workflow%3Aci+branch%3Amain)
[![RuboCop](https://github.com/fixrb/fix/workflows/RuboCop/badge.svg?branch=main)](https://github.com/fixrb/fix/actions?query=workflow%3Arubocop+branch%3Amain)
[![License](https://img.shields.io/github/license/fixrb/fix?label=License&logo=github)](https://github.com/fixrb/fix/raw/main/LICENSE.md)

![Fix specing framework for Ruby](https://github.com/fixrb/fix/raw/main/img/fix.jpg)

## Installation

Add this line to your application's Gemfile:

```ruby
gem "fix", ">= 1.0.0.beta5"
```

And then execute:

```sh
bundle
```

Or install it yourself as:

```sh
gem install fix --pre
```

## Example

Given this app:

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

And this fixed behavior:

```ruby
# examples/duck/fix.rb

relative "fix"

Fix :Duck do
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

When I run this test:

```ruby
# examples/duck/test.rb

require_relative "app"
require_relative "fix"

Fix[:Duck].call(Duck.new)
```

```sh
ruby examples/duck/test.rb
```

I should see this output:

```txt
Test #<Duck:0x00007fc5289bcf68> against Duck:
- NoMethodError: undefined method `sings' for #<Duck:0x00007fc5289bcf68>.
- Success: expected to eql "Swoosh...".
- Success: undefined method `speaks' for #<Duck:0x00007fc5289bcf68>.
```

## Test suite

__Fix__'s specifications are [fixed here](https://github.com/fixrb/fix/blob/main/fix/) and can be tested against __Fix__'s codebase executing [test/](https://github.com/fixrb/fix/blob/main/test/)'s files.

## Contact

* Home page: [https://fixrb.dev/](https://fixrb.dev/)
* Source code: [https://github.com/fixrb/fix](https://github.com/fixrb/fix)
* API Doc: [https://rubydoc.info/gems/fix](https://rubydoc.info/gems/fix)
* Twitter: [https://twitter.com/fix\_rb](https://twitter.com/fix\_rb)

## Versioning

__Fix__ follows [Semantic Versioning 2.0](https://semver.org/).

## License

The [gem](https://rubygems.org/gems/fix) is available as open source under the terms of the [MIT License](https://github.com/fixrb/fix/raw/main/LICENSE.md).

***

<p>
  This project is sponsored by:<br />
  <a href="https://sashite.com/"><img
    src="https://github.com/fixrb/fix/raw/main/img/sashite.png"
    alt="Sashite" /></a>
</p>
