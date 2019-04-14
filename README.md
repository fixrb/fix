# Fix

[![Build Status](https://travis-ci.org/fixrb/fix.svg?branch=master)][travis]
[![Code Climate](https://codeclimate.com/github/fixrb/fix/badges/gpa.svg)][codeclimate]
[![Gem Version](https://badge.fury.io/rb/fix.svg)][gem]
[![Inline docs](http://inch-ci.org/github/fixrb/fix.svg?branch=master)][inchpages]
[![Documentation](http://img.shields.io/:yard-docs-38c800.svg)][rubydoc]
[![Gitter](https://badges.gitter.im/Join%20Chat.svg)][gitter]

> Specing framework for Ruby.

## Contact

* Home page: https://fixrb.dev/
* Bugs/issues: https://github.com/fixrb/fix/issues
* Support: https://stackoverflow.com/questions/tagged/fixrb

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'fix'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install fix

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

Rather than a _random order_ option to help finding bugs somewhere (and sometimes luck), __Fix__ prevents from **side effects** by running each context inside a distinct **sub-process**.  As it behaves like a function, no matter how many times you call it, the build status remains the same.

## Usage

Given this app:

```ruby
# duck.rb
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
# duck_spec.rb
require_relative 'duck'
require 'fix'

@bird = Duck.new

Fix.describe @bird do
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

    $ ruby duck_spec.rb
    ..I

    1. Info: undefined method `sings' for #<Duck:0x007fb60383b740> (NoMethodError).

    Ran 3 tests in 0.00038 seconds
    100% compliant - 1 infos, 0 failures, 0 errors

## Security

As a basic form of security __Fix__ provides a set of SHA512 checksums for
every Gem release.  These checksums can be found in the `checksum/` directory.
Although these checksums do not prevent malicious users from tampering with a
built Gem they can be used for basic integrity verification purposes.

The checksum of a file can be checked using the `sha512sum` command.  For
example:

    $ sha512sum pkg/fix-0.1.0.gem
    d12d7d9c2a4fdfe075cbb7a141fa5f2195175891e4098c7e1a28c8bca655ab44fb9d67b6a2e3991d0f852026c5e4537fdf7e314575c68d1c80b3a4b1eb1c041f  pkg/fix-0.1.0.gem

## Versioning

__Fix__ follows [Semantic Versioning 2.0](http://semver.org/).

## Contributing

1. [Fork it](https://github.com/fixrb/fix/fork)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## License

See `LICENSE.md` file.

[gem]: https://rubygems.org/gems/fix
[travis]: https://travis-ci.org/fixrb/fix
[codeclimate]: https://codeclimate.com/github/fixrb/fix
[gemnasium]: https://gemnasium.com/fixrb/fix
[inchpages]: http://inch-ci.org/github/fixrb/fix
[rubydoc]: http://rubydoc.info/gems/fix/frames
[gitter]: https://gitter.im/fixrb/fix?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge

***

This project is sponsored by:

[![Sashite](https://sashite.com/img/sashite.png)](https://sashite.com/)
