---
layout: post
title: "The Fundamental Distinction Between Expected and Actual Values in Testing"
description: "Explore why the distinction between expected and actual values is crucial in test design, and how it impacts the robustness and reliability of your test suite."
date: 2024-11-04 12:00:00 +0100
author: Cyril Kato
categories:
  - design
  - testing
tags:
  - ruby
  - testing
  - matchi
  - design principles
  - best practices
---
The distinction between expected and actual values in automated testing is more than just a convention - it's a fundamental architectural principle that deserves our attention.

To emphasize the semantic difference between these two values, we must understand that the expected value is a known constant, an integral part of the specification. In contrast, the actual value, obtained by challenging a foreign object, must be evaluated against the expected value by the predicate. This is precisely the role of the latter: to ensure that the obtained value satisfies the criteria defined by the expected value.

This distinction is so fundamental that it must be honored in the very design of the predicate: it receives the expected value as a reference during initialization, then evaluates the actual value against this reference. This asymmetry in value handling reflects their profoundly different nature, a principle that modern testing libraries like [Matchi](https://github.com/fixrb/matchi) have wisely chosen to implement.

Let's illustrate this principle with a concrete example. Consider a simple equivalence test between two strings:

```ruby
EXPECTED_VALUE = "foo"
actual_value = "bar"
```

At first glance, these two approaches seem equivalent:

```ruby
EXPECTED_VALUE.eql?(actual_value) # => false
actual_value.eql?(EXPECTED_VALUE) # => false
```

However, this apparent symmetry can be deceptive. Consider a scenario where the actual value has been compromised:

```ruby
def actual_value.eql?(*)
  true
end

actual_value.eql?(EXPECTED_VALUE) # => true
```

This example, though simplified, highlights a fundamental principle: the predicate must never trust the actual value. Delegating the responsibility of comparison to the latter would mean trusting it for its own evaluation. This is why the predicate must always maintain control of the comparison, using the expected value as a reference to evaluate the actual value, and not the reverse.

This rigorous approach to predicate design contributes not only to the robustness of tests but also to their clarity and long-term maintainability.
