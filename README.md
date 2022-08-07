# Fix

[![Home](https://img.shields.io/badge/Home-fixrb.dev-00af8b)](https://fixrb.dev/)
[![Version](https://img.shields.io/github/v/tag/fixrb/fix?label=Version&logo=github)](https://github.com/fixrb/fix/tags)
[![Yard documentation](https://img.shields.io/badge/Yard-documentation-blue.svg?logo=github)](https://rubydoc.info/github/fixrb/fix/main)
[![Ruby](https://github.com/fixrb/fix/workflows/Ruby/badge.svg?branch=main)](https://github.com/fixrb/fix/actions?query=workflow%3Aruby+branch%3Amain)
[![RuboCop](https://github.com/fixrb/fix/workflows/RuboCop/badge.svg?branch=main)](https://github.com/fixrb/fix/actions?query=workflow%3Arubocop+branch%3Amain)
[![License](https://img.shields.io/github/license/fixrb/fix?label=License&logo=github)](https://github.com/fixrb/fix/raw/main/LICENSE.md)

⚠️ This project is still in the experimental phase. May be used at your own risk.

![Fix specing framework for Ruby](https://fixrb.dev/fix.webp)

## Project goals

* Separate specifications and examples.
* Make specifications documents without logic.
* Provide a rich semantic language.
* Run each test unitarily and quickly.

## Installation

Add this line to your application's Gemfile:

```ruby
gem "fix", ">= 1.0.0.beta8"
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

Given these specifications:

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

When we load this `Duck` application:

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

And we run this test:

```ruby
# examples/duck/test.rb

require_relative "app"
require_relative "fix"

Fix[:Duck].test { Duck.new }
```

```sh
ruby examples/duck/test.rb
```

We should see this output:

```txt
(irb):3 Success: expected #<Duck:0x00007fb2fa208708> to be an instance of Duck.
(irb):7 Success: expected to eq "Swoosh...".
(irb):15 NoMethodError: undefined method `sings' for #<Duck:0x00007fb2fd8371d0>.
(irb):6 Success: expected "Swoosh..." to be an instance of String.
(irb):11 Success: undefined method `speaks' for #<Duck:0x00007fb2fcc79258>.
```

## Contact

* Home page: <https://fixrb.dev/>
* Source code: <https://github.com/fixrb/fix>
* API Doc: <https://rubydoc.info/gems/fix>
* Twitter: <https://twitter.com/fix_rb>

## Versioning

__Fix__ follows [Semantic Versioning 2.0](https://semver.org/).

## License

The [gem](https://rubygems.org/gems/fix) is available as open source under the terms of the [MIT License](https://github.com/fixrb/fix/raw/main/LICENSE.md).

***

This project is sponsored by [Sashité](https://github.com/sashite/):

![Sashité logo](https://github.com/fixrb/fix/raw/main/img/sponsor/dark/en/sashite.png#gh-dark-mode-only "Sashité")
![Sashité logo](https://github.com/fixrb/fix/raw/main/img/sponsor/light/en/sashite.png#gh-light-mode-only "Sashité")
