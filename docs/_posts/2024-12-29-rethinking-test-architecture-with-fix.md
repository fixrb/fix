---
layout: post
title: "Rethinking Test Architecture with Clear Specification Separation"
description: "Discover how Fix's unique approach to testing in Ruby promotes clear separation between specifications and implementation, making your test suite more maintainable and reusable."
author: Cyril Kato
categories:
  - framework
  - testing
tags:
  - fix
  - ruby
  - specifications
  - architecture
  - testing framework
---
In the Ruby development world, testing frameworks like RSpec or Minitest have become industry standards. However, Fix proposes a radically different approach that deserves our attention: a clean separation between specifications and their implementation.

## Traditional Architecture: A Mix of Concerns

Traditionally, Ruby testing frameworks mix the definition of expected behaviors and the concrete examples that verify them in the same file. Let's look at a classic example with RSpec:

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

In this example, the specification (adding two numbers) is wrapped in several layers of setup and context, mixing the what (adding numbers should equal 5) with the how (creating instances, setting up variables).

## The Fix Approach: A Clear Separation of Responsibilities

Fix adopts a radically different philosophy by clearly dividing two aspects:

1. Specifications: pure documents that define expected behaviors
2. Tests: concrete implementations that challenge these specifications

Here's how the same calculator test looks with Fix:

```ruby
# 1. The specification - a pure and reusable document
Fix :Calculator do
  on(:new, 2) do
    on(:add, 3) do
      it MUST be 5
    end
  end
end

# 2. The test - a specific implementation
Fix[:Calculator].test { Calculator }
```

The contrast is striking. Fix's specification is:
- Concise: the expected behavior is expressed in just a few lines
- Clear: the flow from constructor to method call is immediately apparent
- Pure: it describes only what should happen, not how to set it up

This separation brings several major advantages:

### 1. Specification Reusability

Specifications become autonomous documents that can be reused across different implementations. The same calculator specification could be used to test different calculator classes as long as they follow the same interface.

### 2. Isolated Testing

Each test can be executed in complete isolation, which makes debugging easier and improves test code maintainability. The separation between specification and implementation means you can change how you test without changing what you're testing.

## A More Complex Example

Let's see how this separation applies in a more elaborate case:

```ruby
# A generic specification for a payment system
Fix :PaymentSystem do
  with amount: 100 do
    it MUST be_positive

    on :process do
      it MUST be_successful
      it MUST change(account, :balance).by(-100)
    end
  end

  with amount: -50 do
    on :process do
      it MUST raise_exception(InvalidAmountError)
    end
  end
end

# Specific tests for different implementations
Fix[:PaymentSystem].test { StripePayment.new(amount: 100) }
Fix[:PaymentSystem].test { PaypalPayment.new(amount: 100) }
```

In this example, the payment system specification is generic and can be applied to different payment implementations. By focusing on the interface rather than the implementation details, we create a reusable contract that any payment processor can fulfill.

## Benefits in Practice

This architectural separation provides several practical benefits:

1. **Documentation**: Specifications serve as clear, living documentation of your system's expected behavior

2. **Maintainability**: Changes to test implementation don't require changes to specifications

3. **Flexibility**: The same specifications can verify multiple implementations, making it ideal for:
   - Testing different versions of a class
   - Verifying third-party integrations
   - Ensuring consistency across microservices

4. **Clarity**: By separating what from how, both specifications and tests become more focused and easier to understand

## Conclusion

Fix invites us to rethink how we write our tests in Ruby. By clearly separating specifications from concrete tests, it allows us to:

- Create clearer and reusable specifications
- Maintain living documentation of our expectations
- Test different implementations against the same specifications
- Isolate problems more easily

This unique architectural approach makes Fix a particularly interesting tool for projects that require precise and reusable specifications while maintaining great flexibility in their implementation.
