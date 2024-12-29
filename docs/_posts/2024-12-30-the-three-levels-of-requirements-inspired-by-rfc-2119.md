---
layout: post
title: "The Three Levels of Requirements Inspired by RFC 2119"
description: "Discover how Fix implements MUST, SHOULD, and MAY requirement levels for more precise specifications, and how this approach compares to RSpec's historical evolution."
date: 2024-12-30
author: Cyril Kato
categories:
  - framework
  - testing
tags:
  - fix
  - rspec
  - spectus
  - testing
  - must
  - should
  - may
---
In software development, precision in language is crucial. This is particularly true when defining test specifications. Fix, through the Spectus library, introduces three levels of requirements directly inspired by RFC 2119, offering rich and nuanced semantics for your specifications.

## The Three Requirement Levels

### MUST/MUST_NOT: The Absolute

The MUST level represents an absolute requirement of the specification. When you use MUST, you indicate that a feature is mandatory and non-negotiable. Formally, for a test using MUST to pass, the expectation must be conclusively met. If the expectation fails, the test fails unconditionally.

```ruby
Fix :Password do
  it MUST_NOT be_empty
  it MUST have_length_of(8..128)

  with content: "password123" do
    it MUST include_number
    it MUST_NOT be_common_password
  end
end
```

In this example, each test marked with MUST represents a rule that cannot be broken. An empty or too short password is simply not acceptable. The test will fail if any of these conditions are not met, regardless of any other circumstances.

### SHOULD/SHOULD_NOT: The Recommendation

SHOULD indicates a strong recommendation that can be ignored in particular circumstances, but whose implications must be understood and carefully evaluated. From a technical standpoint, if an expectation marked with SHOULD fails, the test can still pass if no exception is raised. This allows for graceful degradation of optional but recommended features.

```ruby
Fix :EmailService do
  on :send, to: "user@example.com" do
    it MUST deliver_email
    it SHOULD be_rate_limited
    it SHOULD_NOT take_longer_than(5.seconds)
  end
end
```

Here, while email delivery is mandatory (MUST), rate limiting is strongly recommended (SHOULD) but could be disabled in specific contexts. If the rate limiting check fails but doesn't raise an exception, the test will still pass, indicating that while the recommendation wasn't followed, the system is still functioning as expected.

### MAY: The Optional

MAY indicates a truly optional feature. In Fix's implementation, a MAY requirement has a unique behavior: the test will pass either if the expectation is met OR if a NoMethodError is raised. This elegantly handles cases where optional features are not implemented at all. This is particularly valuable for specifying features that might be implemented differently across various contexts or might not be implemented at all.

```ruby
Fix :UserProfile do
  on :avatar do
    it MUST be_valid_image
    it SHOULD be_less_than(5.megabytes)
    it MAY be_square
    it MAY support_animation
  end
end
```

In this example:
- The avatar must be a valid image (MUST) - this will fail if not met
- It should be lightweight (SHOULD) - this will pass if it fails without exception
- It may be square (MAY) - this will pass if either:
  1. The expectation is met (the avatar is square)
  2. The method to check squareness isn't implemented (raises NoMethodError)
- Similarly, animation support is optional and can be entirely unimplemented

This three-level system allows for precise specification of requirements while maintaining flexibility in implementation. Here's a more complex example that demonstrates all three levels working together:

```ruby
Fix :Document do
  # Absolute requirements - must pass their expectations
  it MUST have_content
  it MUST have_created_at

  # Strong recommendations - can fail without exception
  it SHOULD have_author
  it SHOULD be_versioned

  # Optional features - can be unimplemented
  it MAY be_encryptable
  it MAY support_collaborative_editing

  on :publish do
    it MUST change(document, :status).to(:published)  # Must succeed
    it SHOULD notify_subscribers             # Can fail gracefully
    it MAY trigger_indexing                  # Can be unimplemented
  end
end
```

## Historical Evolution: From RSpec to Fix

This semantic approach contrasts with RSpec's history. Originally, RSpec used the `should` keyword as its main interface:

```ruby
# Old RSpec style
describe User do
  it "should validate email" do
    user.email = "invalid"
    user.should_not be_valid
  end
end
```

However, this approach had several issues:
- Monkey-patching `Object` to add `should` could cause conflicts
- Using `should` for absolute requirements was semantically incorrect
- Code became harder to maintain due to global namespace pollution

RSpec eventually migrated to the `expect` syntax:

```ruby
# Modern RSpec
describe User do
  it "validates email" do
    user.email = "invalid"
    expect(user).not_to be_valid
  end
end
```

## The Fix Approach: Clarity and Precision

Fix takes a different path by fully embracing RFC 2119 semantics. Here's a complete example illustrating all three levels:

```ruby
Fix :Article do
  # Absolute requirements
  it MUST have_title
  it MUST have_content

  # Strong recommendations
  it SHOULD have_meta_description
  it SHOULD be_properly_formatted

  # Optional features
  it MAY have_cover_image
  it MAY have_comments_enabled

  on :publish do
    it MUST change(article, :status).to(:published)
    it SHOULD trigger_notification
    it MAY be_featured
  end
end

# Test against a specific implementation
Fix[:Article].test { Article.new(title: "Test", content: "Content") }
```

This approach offers several advantages:
- Clear and precise semantics for each requirement level
- No global monkey-patching
- Living documentation that exactly reflects developer intentions
- Better team communication through standardized vocabulary

## Conclusion

Fix's three requirement levels, inherited from Spectus, offer a powerful and nuanced way to express your testing expectations. This approach, combined with the clear separation between specifications and implementations, makes Fix particularly well-suited for writing maintainable and communicative tests.

RSpec's evolution shows us the importance of precise semantics and clean architecture. Fix capitalizes on these lessons while offering a modern and elegant approach to Ruby testing.
