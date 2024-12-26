---
author: "Cyril Kato"
layout: "post"
title: "Tests vs. Specs: Beyond Semantics"
date: "2024-12-26"
tags: [testing-frameworks specifications software-design rspec]
---
The distinction between "writing tests" and "writing specs" may seem purely semantic. Yet it reveals a fundamental confusion in our development practices.

## The Problem with Our Tests

Here's a typical RSpec example:

```ruby
RSpec.describe Calculator do
  subject(:calculator) do
    described_class.new(first_number)
  end

  describe "when first number is 2" do
    let(:first_number) do
      2
    end

    context "#add" do
      let(:second_number) do
        3
      end

      it "adds two numbers" do
        expect(calculator.add(second_number)).to be(5)
      end
    end
  end
end
```

This code has several issues:
- It mixes specification and verification
- It enforces a specific test structure
- It creates tight coupling with the implementation

## A Radical Alternative

Fix proposes a different approach: clearly separating specification from testing.

The specification:
```ruby
Fix :Calculator do
  on(:new, 2) do
    on(:add, 3) do
      it MUST be 5
    end
  end
end
```

The test:
```ruby
Fix[:Calculator].test { Calculator }
```

This separation brings immediate benefits:

1. **Clarity**: The specification expresses only the expected behavior
2. **Reusability**: One spec can validate multiple implementations
3. **Isolation**: Tests become simple verifications

## Towards Better Practice

This separation isn't just aesthetic. It fundamentally changes our development approach:

- Specifications become the source of truth
- Tests reduce to their essence: validation
- Decoupling promotes better design

## Practical Impact

In a real project, this approach enables:
- Quick validation of implementation changes
- Living documentation of expected behavior
- Easier refactoring

Fix doesn't invent these concepts, but it makes them explicit and practical.

## Conclusion

The tests/specs distinction isn't mere wordplay. It's an opportunity to fundamentally rethink our approach to software development. The separation of concerns, a fundamental programming principle, should also apply to our tests.
