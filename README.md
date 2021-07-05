# Fix

[![Version](https://img.shields.io/github/v/tag/fixrb/fix?label=Version&logo=github)](https://github.com/fixrb/fix/releases)
[![Yard documentation](https://img.shields.io/badge/Yard-documentation-blue.svg?logo=github)](https://rubydoc.info/github/fixrb/fix/main)
[![CI](https://github.com/fixrb/fix/workflows/CI/badge.svg?branch=main)](https://github.com/fixrb/fix/actions?query=workflow%3Aci+branch%3Amain)
[![RuboCop](https://github.com/fixrb/fix/workflows/RuboCop/badge.svg?branch=main)](https://github.com/fixrb/fix/actions?query=workflow%3Arubocop+branch%3Amain)
[![License](https://img.shields.io/github/license/fixrb/fix?label=License&logo=github)](https://github.com/fixrb/fix/raw/main/LICENSE.md)

> Specing framework for Ruby.

## Installation

Add this line to your application's Gemfile:

```ruby
gem "fix", ">= 1.0.0.beta4"
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install fix --pre

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

When you run this:

```ruby
# examples/duck/fix.rb

relative "fix"

fix = Fix do
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

require_relative "app"

bird = Duck.new
fix.call(bird)

```

Then the output should look like this:

```sh
ruby examples/duck/fix.rb
```

```txt
examples/duck/fix.rb:8: Success: expected to eql "Swoosh...".
examples/duck/fix.rb:12: Success: undefined method `speaks' for #<Duck:0x00007fe3be868ea0>.
examples/duck/fix.rb:16: NoMethodError: undefined method `sings' for #<Duck:0x00007fe3be868ea0>.
```

## Contact

* Home page: https://fixrb.dev/
* Source code: https://github.com/fixrb/fix

## Versioning

__Fix__ follows [Semantic Versioning 2.0](https://semver.org/).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

***

<p>
  This project is sponsored by:<br />
  <a href="https://sashite.com/"><img
    src="https://github.com/fixrb/fix/raw/master/img/sashite.png"
    alt="Sashite" /></a>
</p>
