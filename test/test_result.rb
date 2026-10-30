# frozen_string_literal: true

require_relative File.join("support", "coverage")
require_relative File.join("..", "lib", "fix")

# A result is data: the location, the chain and the result of Spectus,
# whose verdict and texts it gives.
spectus = Spectus.must(Matchi::Eq.new(1)).call { 1 }
result = Fix::Result.new(location: "spec/a_fix.rb:3", chain: ".size", result: spectus)
raise unless result.frozen? && result.location == "spec/a_fix.rb:3" && result.chain == ".size"
raise unless result.result.equal?(spectus) && result.passed?.equal?(true) && result.outcome == :success
raise unless result.summary == "expected 1 to eq 1" && result.to_s == "spec/a_fix.rb:3: Success: expected 1 to eq 1"
raise unless result == Fix::Result.new(location: "spec/a_fix.rb:3", chain: ".size", result: spectus)
raise unless Marshal.load(Marshal.dump(result)) == result

# A failure and an error.
failure = Fix::Result.new(location: "a:1", chain: "", result: Spectus.must(Matchi::Eq.new(1)).call { 2 })
raise unless failure.passed?.equal?(false) && failure.outcome == :failure
raise unless failure.to_s == "a:1: Failure: expected 2 to eq 1"
error = Fix::Result.new(location: "a:1", chain: "", result: Spectus.must(Matchi::Eq.new(1)).call { raise "boom" })
raise unless error.outcome == :error && error.to_s == "a:1: Error: RuntimeError: boom"

# The text holds on one line, whatever the message.
broken = Spectus.must(Matchi::Eq.new(1)).call { raise "one\ntwo\r\nthree" }
raise unless Fix::Result.new(location: "a:1", chain: "",
                             result: broken).to_s == 'a:1: Error: RuntimeError: one\ntwo\nthree'
raise unless Fix::Result.new(location: "a:1", chain: "", result: broken).to_s.lines.size == 1
