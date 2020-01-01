# Fix

[![Build Status](https://api.travis-ci.org/fixrb/fix.svg?branch=master)][travis]
[![Code Climate](https://codeclimate.com/github/fixrb/fix/badges/gpa.svg)][codeclimate]
[![Gem Version](https://badge.fury.io/rb/fix.svg)][gem]
[![Inline docs](https://inch-ci.org/github/fixrb/fix.svg?branch=master)][inchpages]
[![Documentation](https://img.shields.io/:yard-docs-38c800.svg)][rubydoc]
[![Gitter](https://badges.gitter.im/Join%20Chat.svg)][gitter]

> Specing framework for Ruby.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'fix', '>= 1.0.0.beta1'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install fix --pre

## Let's get started!

[![asciicast](https://asciinema.org/a/29098.png)](https://asciinema.org/a/29098)

## Philosophy

### Simple, stupid

With 174 LOC built on top of [Spectus expectation library](https://github.com/fixrb/spectus), facilities such as benchmarking and mocking are not supported.  __Fix__ offers however a **consistent** DSL to focus your BDD.

### True specifications

While specs behave like **documents** which can be logic-less, their interpretation should not be questioned regardless of the version of __Fix__, preventing from software erosion.  Also, Fix specs are compliant with **[RFC 2119](http://tools.ietf.org/html/rfc2119)**.

### Low code complexity

Monkey-patching, [magic tricks and friends](http://blog.arkency.com/2013/06/are-we-abusing-at-exit/) are not included.  Instead, animated by **authentic** and **unmuted** Ruby objects, unambiguous, understandable and structured specs are encouraged.

### Test in isolation

Rather than a _random order_ option to help finding bugs somewhere (and sometimes luck), __Fix__ provides a protection against **side effects** by allowing to run contexts inside **sub-process**.  As it behaves like a function, no matter how many times you call it, the build status remains the same.

## Usage

Given this app:

```ruby
# examples/duck/app.rb
class Duck
  def walks
    'Klop klop!'
  end

  def swims
    'Swoosh...'
  end

  def quacks
    puts 'Quaaaaaack!'
  end
end
```

When you run this:

```ruby
# examples/duck/fix.rb
require_relative 'app'
require_relative '../../lib/fix'

@bird = Duck.new

Fix(@bird) do
  on :swims do
    it { MUST eql 'Swoosh...' }
  end

  on :speaks do
    it { MUST raise_exception NoMethodError }
  end

  on :sings do
    it { MAY eql '♪... ♫...' }
  end
end
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
* Bugs/issues: https://github.com/fixrb/fix/issues
* Support: https://stackoverflow.com/questions/tagged/fixrb

## Rubies

* [MRI](https://www.ruby-lang.org/)
* [Rubinius](https://rubinius.com/)
* [JRuby](https://www.jruby.org/)

## Versioning

__Fix__ follows [Semantic Versioning 2.0](http://semver.org/).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

***

<p>
  This project is sponsored by:<br />
  <a href="https://sashite.com/"><img
    src="https://github.com/fixrb/fix/raw/master/img/sashite.png"
    alt="Sashite" /></a>
</p>

[travis]: https://travis-ci.org/fixrb/fix
[codeclimate]: https://codeclimate.com/github/fixrb/fix
[gem]: https://rubygems.org/gems/fix
[inchpages]: http://inch-ci.org/github/fixrb/fix
[rubydoc]: http://rubydoc.info/gems/fix/frames
[gitter]: https://gitter.im/fixrb/fix?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge
