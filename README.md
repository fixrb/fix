# Fix

[![Version](https://img.shields.io/github/v/tag/fixrb/fix?label=Version&logo=github)](https://github.com/fixrb/fix/tags)
[![Yard documentation](https://img.shields.io/badge/Yard-documentation-blue.svg?logo=github)](https://rubydoc.info/github/fixrb/fix/main)
[![License](https://img.shields.io/github/license/fixrb/fix?label=License&logo=github)](https://github.com/fixrb/fix/raw/main/LICENSE.md)

Fix writes a specification: what a subject MUST, SHOULD or MAY do, with the words of [RFC 2119](https://www.rfc-editor.org/rfc/rfc2119), and nothing about how the subject is made. The specification is then tested against a subject, each context in a child process, and every expectation gets a result.

The [guide](https://fixrb.dev/gems/fix/v1/) teaches Fix one page at a time, from a first specification to the tests of a project; [fixrb.dev](https://fixrb.dev/gems/fix/) tells what a specification is for, and answers the [questions](https://fixrb.dev/gems/fix/v1/questions/) that come up.

## Installation

```ruby
# Gemfile
gem "fix"
```

Fix requires Ruby 3.3 or later on a system with `fork`, and depends on [Aw](https://github.com/fixrb/aw), [Defi](https://github.com/fixrb/defi), [Matchi](https://github.com/fixrb/matchi) and [Spectus](https://github.com/fixrb/spectus).

## Usage

A file writes a specification, then tests a subject against it:

```ruby
# duck_fix.rb
require "fix"

class Duck
  def walk = "Klop klop!"
  def swim = "Swoosh..."
end

Fix :Duck do
  on :walk do
    it MUST eq "Klop klop!"
  end

  on :swim do
    it MUST eq "Swoosh..."
  end

  on :speak do
    it MAY eq "Quaaaaaack!"
  end
end

exit(Fix[:Duck].test { Duck.new })
```

```text
duck_fix.rb:11: Success: expected "Klop klop!" to eq "Klop klop!"
duck_fix.rb:15: Success: expected "Swoosh..." to eq "Swoosh..."
duck_fix.rb:19: Info: NoMethodError: undefined method 'speak' for an instance of Duck
```

`Fix :Duck do … end` builds the specification and registers it under its name; `Fix[:Duck]` finds it again. `test` builds a new subject with the block for every expectation, sends it the methods of the `on` around it, judges what comes out, writes one line per expectation, the backtrace of an error below it, and returns whether all of them pass (`true` when there is nothing to test). `exit` turns that into the status of the process: 0 when the specification is met, 1 otherwise.

Keep the parentheses: `exit Fix[:Duck].test do … end` gives the block to `exit`, and `test` raises `ArgumentError` for want of one. A file with several specifications tests them all before it exits, as `exit([Fix[:A].test { … }, Fix[:B].test { … }].all?)` does.

## Writing a specification

The block of `Fix` is a document, read once when the file is loaded, with four words: `let`, `with`, `on` and `it`. Each `with`, each `on` opens a context, which inherits from the one around it.

### `on`

`on :name, *arguments, **keywords` sends a method to the subject, and the expectations inside judge what it returns. The `on` inside an `on` send their method to that value, and so on; with no `on` around, an expectation judges the subject itself.

```ruby
require "fix"

Fix :Answer do
  it MUST be_an_instance_of Integer

  on :+, 2 do
    it MUST eq 44
  end

  on :to_s do
    on :size do
      it MUST eq 2
    end
  end

  on :digits do
    it MUST eq [2, 4]
  end
end

exit(Fix[:Answer].test { 42 })
```

```text
example.rb:4: Success: expected 42 to be an instance of Integer
example.rb:7: Success: expected 44 to eq 44
example.rb:12: Success: expected 2 to eq 2
example.rb:17: Success: expected [2, 4] to eq [2, 4]
```

A method that raises ends the chain there, and the expectation judges the exception: an error for most matchers, what `raise_exception` is for. There is no helper for a predicate: `on(:empty?) { it MUST be_true }` asks the question. The method is sent without a block, since the block of `on` is the context: a method that needs one is called in the subject block, or tested with `satisfy`. A `BasicObject` has no `public_send`, so an `on` sent to it is an error.

### `let` and `with`

A `let` is a parameter of the subject: a name and a block, for the block of `test` to call when it builds the subject. Its value is computed the first time it is called and kept for the rest of the expectation, and a `let` may call another. `with name: value` opens a context where the parameter has that value.

```ruby
require "fix"

Fix :Greeting do
  let(:name) { "Bob" }

  it MUST eq "Hello, Bob!"

  with name: "Alice" do
    it MUST eq "Hello, Alice!"
  end
end

exit(Fix[:Greeting].test { "Hello, #{name}!" })
```

```text
example.rb:6: Success: expected "Hello, Bob!" to eq "Hello, Bob!"
example.rb:9: Success: expected "Hello, Alice!" to eq "Hello, Alice!"
```

The block of `test` runs on a fresh object for every expectation, where the lets of its context are methods: it sees them, and sees `Kernel` and the methods of the top level as any code does, but not the instance variables of the file. The value of a `with` is the object given, shared by the expectations of its context: `with items: []` gives the same array to each of them, where `let(:items) { [] }` gives a new one to each.

A let is visible from the subject and from the other lets only. Named in an expectation, where it would be read before any subject exists, it raises `NameError` at load, with the remedy: `name is a let, visible in the subject block and in other lets only`. Its name cannot be a method of the object the subject is built on, public or private, nor a word of the language, so that nothing is redefined in silence: `let(:format)`, `let(:p)` or `let(:it)` raise `ArgumentError` at load, naming the owner or the word (`format is already a method of Kernel`, `it is a word of the specification language`). A `with` has the same rule, and declares the lets it names: a name no `let` declared is a new parameter, not a mistake. A context may declare a name once, inherits the lets declared above it in the contexts around it, and may give a new value to one of them.

### `it`

`it` takes a requirement, not a block: a level, then a matcher, as in `it MUST eq 42`. The levels are `MUST`, `MUST_NOT`, `SHOULD`, `SHOULD_NOT` and `MAY`, the words of RFC 2119, which has no negative MAY. The matchers are those of Matchi:

| Word | Meets when the actual value… |
|------|------------------------------|
| `eq(expected)` | is `eql?` to the expected one |
| `be(expected)` | is the very same object (`equal?`) |
| `be_true`, `be_false`, `be_nil` | is `true`, `false`, `nil` |
| `be_within(delta).of(expected)` | is a number within the delta |
| `match(regexp)` | is a String or a Symbol that matches |
| `be_an_instance_of(klass)` | is an instance of that very class |
| `be_a_kind_of(mod)` | is an instance of that module or of a descendant |
| `raise_exception(klass, message = nil)` | is an exception of that class or of a subclass, with that message (a String, or a Regexp to match) when given |
| `change(object, :method)`, `.by(n)`, `.by_at_least(n)`, `.by_at_most(n)`, `.from(a).to(b)`, `.to(b)` | makes that method of that object change, so when refined |
| `satisfy { \|value\| … }` | makes the block answer `true`; an answer that is neither `true` nor `false` is an error |
| `fix(:Name)`, `fix { … }` | meets that specification, by name or written here |

Any other object with `match?` and `to_s` is a matcher too. The object of a `change` must exist when the file is loaded, since the matcher is built there: a let, which lives with the subject, cannot be observed. A specification is a matcher that tests its expectations against the actual value, so one specification may require another:

```ruby
require "fix"

Fix :Positive do
  on :positive? do
    it MUST be_true
  end
end

Fix :Score do
  it MUST be_a_kind_of Numeric
  it MUST fix(:Positive)
end

exit(Fix[:Score].test { 7 })
```

```text
example.rb:10: Success: expected 7 to be a kind of Numeric
example.rb:11: Success: expected 7 to fix Positive
```

A failed `fix` says that the specification is not met, not which of its expectations failed: test the specification on its own for that.

In Ruby 3.4 and later, a bare `it` in a block is the parameter of the block, while `it` with a requirement is the word of Fix, as before; on Ruby 3.3 the bare `it` is the word of Fix too. A `satisfy` meant for both names its parameter: `satisfy { |value| … }`.

The document runs on an instance of `Fix::Dsl`, and a gem may add a word to it that composes `on` and `it`: fix-its adds `its`. Such a word gives `it` the `location:` of its own caller, what `caller_locations(1, 1).first` gives, an object with `path` and `lineno`, so that the result points at the line of the specification.

### Loading

The specification is built when its block runs, before any subject exists, and nothing in it waits for a test: a name that is not a Symbol, a name already registered, a `let`, a `with` or an `on` without a block, a `with` without a value, an `it` with a block or without a requirement, a matcher without `match?` or whose `to_s` is not a `String`, raise then. A block that raises registers nothing. `Fix[:Name]` raises `KeyError` for a name it does not know, and `fix(:Name)` finds its specification then: write it first.

`Fix.spec(:Name) { … }` is the method `Fix` calls; without a name, both give a specification that is not registered. The registry is written by the thread that loads the file, read afterwards, and never emptied: a runner runs each file in a process of its own.

## Outcomes

Two questions tell the levels apart. Does the method exist? MUST and SHOULD require it, MAY does not. Does it do what is specified? MUST and MAY require it, SHOULD recommends it. Hence five outcomes:

| Level  | Match is true | Match is false | Missing method | Other exception |
|--------|---------------|----------------|----------------|-----------------|
| MUST   | success       | failure        | error          | error           |
| SHOULD | success       | warning        | error          | error           |
| MAY    | success       | failure        | info           | error           |

A negation swaps the first two columns. A success, a warning and an info pass; a failure and an error do not. The missing method is the one named by the `on` of the context, when sending it raises `NoMethodError` for that method on that object, as the duck has no `speak`; Spectus adds the method a matcher calls on the actual value. A private method counts as missing, as does a method that exists and raises `NoMethodError` for itself; a method that raises `NoMethodError` on another object is an error.

```ruby
# account_fix.rb
require "fix"

class Account
  def initialize(balance)
    @balance = balance
  end

  attr_reader :balance

  def withdraw(amount)
    raise ArgumentError, "insufficient funds" if amount > balance

    @balance -= amount
  end
end

Fix :Account do
  on :balance do
    it MUST eq 100
    it MUST eq 200
    it SHOULD eq 200
  end

  on :currency do
    it MAY eq "EUR"
  end

  on :withdraw, 500 do
    it MUST eq(-400)
  end
end

exit(Fix[:Account].test { Account.new(100) })
```

```text
account_fix.rb:20: Success: expected 100 to eq 100
account_fix.rb:21: Failure: expected 100 to eq 200
account_fix.rb:22: Warning: expected 100 to eq 200
account_fix.rb:26: Info: NoMethodError: undefined method 'currency' for an instance of Account
account_fix.rb:30: Error: ArgumentError: insufficient funds
  account_fix.rb:12:in 'Account#withdraw'
  account_fix.rb:34:in '<main>'
```

## Results

`test` writes on `$stdout`, for each expectation, one line: its location in the file, the outcome, and the summary of Spectus, `expected ACTUAL to DESCRIPTION`, with `not` for a negation, or `CLASS: MESSAGE`. A line break in either is written `\n`; a backslash stays as it is, the line being for reading, not for reading back. Below an error come the frames of its backtrace that are not in Fix, Aw, Defi, Matchi or Spectus, indented by two spaces. Nothing else is written: no letter, no colour, no count. What the subject writes on the standard output comes out as it is, before the lines of its context, so a text left without a line break joins the first of them.

That grammar, `LOCATION: OUTCOME: SUMMARY` then indented continuation lines, is what a runner reads: the location up to the first `:LINE: OUTCOME: ` of the line, the outcome one of the five words. What the subject writes is beyond the runner's reach; the status of the process is not.

`run` gives the same results as data, an `Array` of `Fix::Result` in the order of the contexts, a context before those inside it, and of the expectations within a context:

```ruby
require "fix"

Fix :Size do
  it MUST be_an_instance_of String

  on :size do
    it MUST eq 3
  end
end

results = Fix[:Size].run { "abcd" }
results.map(&:outcome) # => [:success, :failure]
results.map(&:passed?) # => [true, false]
result = results.last
result.location # => "example.rb:7"
result.chain # => ".size"
result.summary # => "expected 4 to eq 3"
result.to_s # => "example.rb:7: Failure: expected 4 to eq 3"
result.result.class # => Spectus::Result
Fix[:Size].match? { "abc" } # => true
```

`location` is the file and the line of the `it`, relative to the current directory when under it; `chain` is the methods sent to the subject, as written after a dot with the arguments by their `inspect`, empty for the subject itself; `result` is the `Spectus::Result`, with its `level`, `negate`, `description`, `actual`, `error_class`, `error_message` and `backtrace`, unfiltered. `passed?`, `outcome` and `summary` are those of the result. A result is plain data, frozen.

`match?` tests a value, as a matcher does: the block is called once, where `match?` is called, and its value is the subject of every expectation, so the contexts cannot build it anew with their lets: a specification meant for `fix` is written without `with`.

## Processes

Each context with expectations runs in a child process, forked from the one that tests: a subject that leaves something behind cannot touch the next context, and what it raises, an `exit` included, is an error of its expectation alone. The contexts run one after the other, a context before those inside it, and `test` writes the results of a context when its child returns them.

Nothing is rescued around a child, and Fix never writes a result that did not come from an expectation. An `Interrupt`, or a signal the child could trap, is raised again in the parent and stops the run. So does `Aw::ChildError`, for a child that died, was killed or left by `exit!`, or that a `break`, a `return` or a `throw` in the subject block left without a result: the results of the other expectations of its context are lost with it. The children a `fix` matcher forks are inside a matcher, so what they raise is an error of that expectation. On a Ruby without `fork`, a context with expectations raises `NotImplementedError`.

Each child starts as a copy of the parent, with its memory, its signal handlers and its open files, and ends with `exit!`, which runs no `at_exit` handler. Hence a `Random` seeded in the file gives every context the same sequence, while Ruby reseeds `Kernel#rand` in each child; what a subject writes to an IO other than the standard output and error is lost unless it flushes; and what SimpleCov measures in a child is lost, unless the result is stored before `exit!`, as the tests of Fix do, or the run uses `fork: false`. A subject that forks ends its child with `exit!`, as test code does: a child that runs on into Fix instead, by an `exit` or by nothing at all, is ended by Fix without a result. A `Timeout` or a signal the parent could trap asks the child to leave with `TERM`, and kills it half a second later if it is still there: the children a `fix` matcher forks are reaped with it, unless one ignores `TERM`, but a subject's own children run on until their work ends. A specification that requires itself at run time, through `satisfy` say, forks without end, and at the process limit a fork waits for a free slot rather than failing. The cost of a context is one fork of the testing process, a few milliseconds.

`test(fork: false) { … }` and `run(fork: false) { … }` run the contexts in the process itself, for a debugger: an `exit!` of the subject then ends the process, what one context leaves behind reaches the next, and a `fix` matcher still forks.

## Changes in 1.0.1

- Requires aw 1.0.1: a `Timeout` or a trappable signal in the parent asks the child to leave with `TERM` and kills it half a second later, so that the children a `fix` matcher forks are reaped with it; 1.0.0 accepted aw 1.0.0, which killed the child at once and left them running.
- Documentation: `let(:it)` names the word of the language it collides with, not an owner.

## Versioning

Fix follows [Semantic Versioning 2.0](https://semver.org/).

## License

The [gem](https://rubygems.org/gems/fix) is available as open source under the terms of the [MIT License](https://github.com/fixrb/fix/raw/main/LICENSE.md).

## Sponsors

This project is sponsored by [Sashité](https://sashite.com/)
