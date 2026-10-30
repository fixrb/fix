# frozen_string_literal: true

require "rbconfig"

require_relative File.join("support", "coverage")
require_relative File.join("..", "lib", "fix")

# Fix.spec builds a specification, registered under its name once built.
spec = Fix.spec(:Registered) { it MUST eq 1 }
raise unless spec.instance_of?(Fix::Spec) && spec.name == :Registered && spec.nodes.size == 1
raise unless Fix[:Registered].equal?(spec) && spec.frozen?
raise unless spec.to_s == "fix Registered" && spec.inspect == "fix Registered"

# An anonymous specification is not registered.
anonymous = Fix.spec { it MUST eq 1 }
raise unless anonymous.name.nil? && anonymous.to_s == "fix an anonymous specification"

# The name is a Symbol, given once; a block is required; a block that
# raises registers nothing.
error = begin
  Fix.spec("String") { nil }
rescue ArgumentError => e
  e
end
raise unless error.message == "the name must be a Symbol"
error = begin
  Fix.spec(:Registered) { nil }
rescue ArgumentError => e
  e
end
raise unless error.message == ":Registered is already a specification"
# The name is checked once the block ran: a block that registers the same
# name is not overwritten in silence.
error = begin
  Fix.spec(:Nested) { Fix.spec(:Nested) { it MUST eq 2 } }
rescue ArgumentError => e
  e
end
raise unless error.message == ":Nested is already a specification"
raise unless Fix[:Nested].nodes.first.expectations.first.requirement.matcher.to_s == "eq 2"
error = begin
  Fix.spec(:Silent)
rescue ArgumentError => e
  e
end
raise unless error.message == "a block must be given"
error = begin
  Fix.spec(:Broken) { it MUST 42 }
rescue ArgumentError => e
  e
end
raise unless error.message == "the matcher must respond to match?"
error = begin
  Fix[:Broken]
rescue KeyError => e
  e
end
raise unless error.message == "no specification named :Broken" && error.key == :Broken
raise unless error.receiver.key?(:Registered)
raise unless error.receiver.frozen?
# The registry is frozen from the start, before any specification: a fresh
# process says so.
fresh = 'require "fix"; Fix[:None] rescue exit($!.receiver.frozen? && $!.receiver.empty?)'
raise unless system(RbConfig.ruby, "-I", File.expand_path(File.join("..", "lib"), __dir__), "-e", fresh)

# The Fix method is Kernel's, private: it builds a specification at the top
# level of a file, not on an object.
raise unless Kernel.private_method_defined?(:Fix)
raise if Kernel.public_method_defined?(:Fix)
named = Fix(:ByKernel) { it MUST eq 1 }
raise unless Fix[:ByKernel].equal?(named)
raise unless Fix { it MUST eq 1 }.name.nil?
error = begin
  42.Fix(:Nope) { nil }
rescue NoMethodError => e
  e
end
raise unless error.message.include?("private method")
