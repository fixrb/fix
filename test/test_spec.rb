# frozen_string_literal: true

require_relative File.join("support", "coverage")
require_relative File.join("..", "lib", "fix")
require_relative File.join("support", "helpers")

class FixTestDuck
  def swims = "Swoosh..."
  def speaks = raise(NoMethodError.new("not here", :speaks, receiver: self))
  DEEP = __LINE__ + 1
  def deep = raise(ZeroDivisionError, "deep")
end

# run tests a subject against every expectation, each context in a child
# process, and gives one result per expectation, in the order of the
# contexts: a result holds the location, the chain and the result of
# Spectus.
duck_line = __LINE__
duck = Fix.spec do
  it MUST be_an_instance_of FixTestDuck
  on(:swims) { it MUST eq "Swoosh..." }
  on(:swims) { on(:length) { it SHOULD eq 1 } }
  on(:speaks) { it MUST raise_exception NoMethodError }
  on(:sings) { it MAY eq "♪" }
  on(:sings) { it SHOULD eq "♪" }
  on(:deep) { it MUST eq 1 }
  it MUST_NOT eq 1
end
results = duck.run { FixTestDuck.new }
raise unless results.size == 8 && results.all? { |result| result.instance_of?(Fix::Result) && result.frozen? }
raise unless results.all? { |result| result.location.frozen? && result.chain.frozen? }
raise unless results.map(&:outcome) == %i[success success success warning success info error error]
raise unless results.map(&:chain) == ["", "", ".swims", ".swims.length", ".speaks", ".sings", ".sings", ".deep"]
locations = [2, 9, 3, 4, 5, 6, 7, 8].map { |offset| "test/test_spec.rb:#{duck_line + offset}" }
raise unless results.map(&:location) == locations
raise unless results[2].to_s == "#{locations[2]}: Success: expected \"Swoosh...\" to eq \"Swoosh...\""
raise unless results[3].summary == "expected 9 to eq 1"
raise unless results[5].to_s.start_with?("test/test_spec.rb:#{duck_line + 6}: Info: NoMethodError: undefined method")
raise unless results[5].to_s.end_with?("sings' for an instance of FixTestDuck")
raise unless results[6].outcome == :error && results[6].result.error_class == "NoMethodError"
raise unless results[7].result.error_class == "ZeroDivisionError" && results[7].result.error_message == "deep"
raise unless results[7].result.backtrace.first.include?("test/test_spec.rb:#{FixTestDuck::DEEP}")
raise unless results.map(&:passed?) == [true, true, true, true, true, true, false, false]

# Each context runs in a child process; fork: false runs it here.
parent = Process.pid
pids_line = __LINE__
pids = Fix.spec do
  it MUST(satisfy { |pid| pid != parent })
  on(:itself) { it MUST(satisfy { |pid| pid != parent }) }
end
raise unless pids.run { Process.pid }.all?(&:passed?)
raise unless pids.run(fork: false) { Process.pid }.map(&:outcome) == %i[failure failure]
raise unless Fix.spec { it MUST eq 42 }.run(fork: false) { 42 }.first.passed?
passed, output = printed { pids.test { Process.pid } }
raise unless passed.equal?(true)
written = output.lines.map { |text| text[/\A\S+/] }
raise unless written == ["test/test_spec.rb:#{pids_line + 2}:", "test/test_spec.rb:#{pids_line + 3}:"]

# A MAY on a method the subject does not have is an info: the method of
# the on is missing on the very object it is sent to. A method missing
# further down, on another object, or a NoMethodError the method raises
# itself, is an error at every level, as is a missing method under MUST
# or SHOULD.
missing = Fix.spec { on(:nope) { it MAY eq 1 } }
raise unless missing.run { FixTestDuck.new }.first.outcome == :info
raise unless Fix.spec { on(:swims) { on(:nope) { it MAY eq 1 } } }.run { FixTestDuck.new }.first.outcome == :info
raise unless Fix.spec { on(:speaks) { it MAY eq 1 } }.run { FixTestDuck.new }.first.outcome == :info
raise unless Fix.spec { on(:swims) { it MAY eq 1 } }.run { FixTestDuck.new }.first.outcome == :failure
raise unless Fix.spec { on(:nope) { it MUST eq 1 } }.run { FixTestDuck.new }.first.outcome == :error
raise unless Fix.spec { on(:nope) { it SHOULD eq 1 } }.run { FixTestDuck.new }.first.outcome == :error
proxy = Object.new
def proxy.forward = Object.new.nope
raise unless Fix.spec { on(:forward) { it MAY eq 1 } }.run { proxy }.first.outcome == :error
renamed = Object.new
def renamed.call = raise(NoMethodError.new("other", :other, receiver: self))
raise unless Fix.spec { on(:call) { it MAY eq 1 } }.run { renamed }.first.outcome == :error
by_hand = Object.new
def by_hand.call = raise(NoMethodError, "no receiver")
raise unless Fix.spec { on(:call) { it MAY eq 1 } }.run { by_hand }.first.outcome == :error
raise unless Fix.spec { it MAY eq 1 }.run { FixTestDuck.new.nope }.first.outcome == :error
raise unless Fix.spec { on(:itself) { it MAY(satisfy { Object.new.nope }) } }.run { 1 }.first.outcome == :error
# A receiver that denies being itself, and an exception that lies about its
# receiver and its name, are read as Ruby does.
denier = Object.new
denier.define_singleton_method(:equal?) { |_other| false }
raise unless Fix.spec { on(:nope) { it MAY eq 1 } }.run { denier }.first.outcome == :info
raise unless Fix.spec { on(:nope) { it MAY satisfy(&:nope) } }.run { denier }.first.outcome == :info
lying = Object.new
def lying.call
  error = NoMethodError.new("lie", :call, receiver: self)
  error.define_singleton_method(:receiver) { Object.new }
  error.define_singleton_method(:name) { :other }
  raise error
end
raise unless Fix.spec { on(:call) { it MAY eq 1 } }.run { lying }.first.outcome == :info
# The rule of Spectus, for the method a matcher calls on the actual value,
# applies too.
raise unless Fix.spec { it MAY satisfy(&:nope) }.run { 1 }.first.outcome == :info
raise unless Fix.spec { on(:itself) { it MAY satisfy(&:nope) } }.run { 1 }.first.outcome == :info
# The matcher may rescue it: a MAY raise_exception on a missing method is
# a success, and no info.
raise unless Fix.spec { on(:nope) { it MAY raise_exception NoMethodError } }.run { 1 }.first.outcome == :success
raise unless Fix.spec { on(:nope) { it MAY raise_exception KeyError } }.run { 1 }.first.outcome == :failure
# A method missing because it is private counts as missing too.
hidden = Object.new
hidden.singleton_class.define_method(:secret) { 1 }
hidden.singleton_class.send(:private, :secret)
raise unless Fix.spec { on(:secret) { it MAY eq 1 } }.run { hidden }.first.outcome == :info

# The chain stops at the first method that raises; what it raised reaches
# the matcher, which may expect it.
stops = Fix.spec { on(:deep) { on(:never) { it MUST raise_exception ZeroDivisionError } } }
raise unless stops.run { FixTestDuck.new }.first.outcome == :success
raise unless stops.run do
  FixTestDuck.new
end.first.summary == "expected #<ZeroDivisionError: deep> to raise exception ZeroDivisionError"

# The subject is built in a new environment for each expectation, where
# the lets live, each computed once; a with gives the object itself, shared
# by the expectations of its context.
built = 0
fresh = Fix.spec do
  let(:items) { [] }
  let(:count) { items.size }
  it MUST eq [1]
  it MUST eq [1]
end
raise unless fresh.run { built += 1; items << (count + 1) }.map(&:outcome) == %i[success success] # rubocop:disable Style/Semicolon
raise unless built.zero?
raise unless fresh.run(fork: false) { built += 1; items << (count + 1) }.all?(&:passed?) && built == 2 # rubocop:disable Style/Semicolon
shared = Fix.spec do
  with(items: []) do
    on(:first) { it MUST eq [:a] }
    on(:first) { it MUST eq %i[a a] }
  end
end
raise unless shared.run { [items << :a] }.map(&:outcome) == %i[success failure]
raise unless shared.run(fork: false) { [items << :a] }.map(&:outcome) == %i[success success]
within = Fix.spec { with(items: []) { on(:first) { it MUST eq [:a]; it MUST eq %i[a a] } } } # rubocop:disable Style/Semicolon
raise unless within.run { [items << :a] }.map(&:outcome) == %i[success success]
# The arguments of an on are sent with the method.
raise unless Fix.spec { on(:round, half: :even) { it MUST eq 2 } }.run { 2.5 }.first.passed?
raise unless Fix.spec { on(:fetch, 1, 9) { it MUST eq 9 } }.run { [1] }.first.passed?
# A let is computed once per expectation, and the subject block sees no
# instance variable of the file.
@secret = 1
once = Fix.spec do
  let(:value) { rand }
  it MUST be_true
end
raise unless once.run { value.equal?(value) }.first.passed?
raise unless Fix.spec { it MUST be_nil }.run { @secret }.first.passed?
# A name that is not a let, in the subject block, is an ordinary NameError.
raise unless Fix.spec { it MUST eq 1 }.run { prce }.first.result.error_class == "NameError"
raise unless Fix.spec { it MUST eq 1 }.run { @secret }.first.summary == "expected nil to eq 1"

# What the subject raises is an error, exit included; what goes through
# Spectus goes through Fix, and a dead child ends the run.
raise unless Fix.spec { it MUST eq 1 }.run { exit 3 }.first.result.error_class == "SystemExit"
raise unless raised { Fix.spec { it MUST eq 1 }.run { raise Interrupt } }.instance_of?(Interrupt)
raise unless raised { Fix.spec { it MUST eq 1 }.run(fork: false) { raise Interrupt } }.instance_of?(Interrupt)
raise unless raised { Fix.spec { it MUST eq 1 }.run { exit! 2 } }.instance_of?(Aw::ChildError)
raise unless raised { Fix.spec { it MUST eq 1 }.run { Process.kill(:KILL, Process.pid) } }.instance_of?(Aw::ChildError)
# A subject that forks and lets its child run on: that child is not the one
# Fix forked, and delivers nothing.
forking = Fix.spec { it MUST eq 1; it MUST eq 1 } # rubocop:disable Style/Semicolon
def forking_subject = (child = fork; exit 0 if child.nil?; Process.wait(child); 1) # rubocop:disable Style/Semicolon
raise unless forking.run { forking_subject }.map(&:outcome) == %i[success success]
raise unless forking.run(fork: false) { forking_subject }.all?(&:passed?)
# Without fork, a context with expectations raises; one without does not.
raise unless Aw.fork! do
  Aw.singleton_class.prepend(Module.new { def supported? = false })
  [Fix.spec { on(:a) { nil } }.test { 1 }, raised { Fix.spec { it MUST eq 1 }.run { 1 } }.class.name]
end == [true, "NotImplementedError"]

# run, test and match? need a block.
error = raised { duck.run }
raise unless error.instance_of?(ArgumentError) && error.message == "a block must be given"
error = raised { duck.test }
raise unless error.instance_of?(ArgumentError) && error.message == "a block must be given"
error = raised { duck.match? }
raise unless error.instance_of?(ArgumentError) && error.message == "a block must be given"

# test writes each result as its context ends, one line each, with the
# frames of an error that are not those of fix and its gems, and tells
# whether every expectation is met.
passed, output = printed { duck.test { FixTestDuck.new } }
raise unless passed.equal?(false)
lines = output.lines(chomp: true)
frames, reported = lines.partition { |line| line.start_with?("  ") }
raise unless reported.size == 8 && frames.size > 2
raise unless lines[0].start_with?("test/test_spec.rb:#{duck_line + 2}: Success: expected #<FixTestDuck:0x")
raise unless lines[1].start_with?("test/test_spec.rb:#{duck_line + 9}: Success: expected #<FixTestDuck:0x")
raise unless lines[1].end_with?("> not to eq 1")
raise unless lines[6].start_with?("test/test_spec.rb:#{duck_line + 7}: Error: NoMethodError: undefined method")
raise unless lines[7].start_with?("  ") && lines[7].include?("test/test_spec.rb:")
deep = lines.index("test/test_spec.rb:#{duck_line + 8}: Error: ZeroDivisionError: deep")
raise unless lines[deep + 1].start_with?("  ") && lines[deep + 1].include?("test/test_spec.rb:#{FixTestDuck::DEEP}:in ")
raise unless lines[deep + 1].include?("deep")
# A frame follows an error line or another frame only.
raise unless lines.each_cons(2).all? do |before, line|
  !line.start_with?("  ") || before.start_with?("  ") || before.include?(": Error: ")
end
libraries = $LOADED_FEATURES.grep(%r{/(aw|defi|matchi|spectus)\.rb\z}).map { |file| File.dirname(file) }
libraries << File.expand_path(File.join("..", "lib"), __dir__)
raise unless libraries.size == 5
raise if frames.any? { |frame| libraries.any? { |directory| frame.start_with?("#{directory}/") } }
passed, output = printed { Fix.spec { it MUST eq 1 }.test { 1 } }
raise unless passed.equal?(true) && output == "test/test_spec.rb:#{__LINE__ - 1}: Success: expected 1 to eq 1\n"
passed, output = printed { Fix.spec { it MUST eq 1 }.test(fork: false) { 1 } }
raise unless passed.equal?(true) && output.lines.size == 1
passed, output = printed { Fix.spec { on(:a) { nil } }.test { 1 } }
raise unless passed.equal?(true) && output.empty?
# The lines of a context are written as its child ends, before the next
# context runs: a subject of the next one sees them.
stream = StringIO.new
seen = []
spying = Fix.spec do
  it MUST eq 0
  on(:itself) { it MUST eq 1 }
end
begin
  stdout = $stdout
  $stdout = stream
  spying.test(fork: false) { seen.push(stream.string.lines.size).size - 1 }
ensure
  $stdout = stdout
end
raise unless seen == [0, 1] && stream.string.lines.size == 2
# A failure in a context does not stop the others: every line is written.
passed, output = printed { Fix.spec { it MUST eq 2; on(:succ) { it MUST eq 2 } }.test { 1 } } # rubocop:disable Style/Semicolon
raise unless passed.equal?(false) && output.lines.size == 2
# A message spanning several lines stays on one.
multiline = Object.new
def multiline.call = raise("one\ntwo")
passed, output = printed { Fix.spec { on(:call) { it MUST eq 1 } }.test { multiline } }
raise unless passed.equal?(false)
raise unless output.lines.first.chomp == "test/test_spec.rb:#{__LINE__ - 2}: Error: RuntimeError: one\\ntwo"
# An error without a backtrace prints its line only; a frame spanning
# several lines stays on one too.
traceless = Object.new
def traceless.call = raise(Class.new(StandardError) { def backtrace = nil }, "bare")
passed, output = printed { Fix.spec { on(:call) { it MUST eq 1 } }.test { traceless } }
raise unless passed.equal?(false) && output.lines.size == 1
forged = Object.new
def forged.call = raise(Class.new(StandardError) { def backtrace = ["x.rb:1:in 'a'\r\nx.rb:2: Success: forged"] })
passed, output = printed { Fix.spec { on(:call) { it MUST eq 1 } }.test { forged } }
raise unless passed.equal?(false) && output.lines(chomp: true).last == "  x.rb:1:in 'a'\\nx.rb:2: Success: forged"

# match? tests a value, as a matcher does: the block is called once, the
# value is the subject of every expectation, and a mutation by a context
# does not reach the others.
calls = 0
raise unless duck.match? { calls += 1; FixTestDuck.new }.equal?(false) # rubocop:disable Style/Semicolon
raise unless calls == 1
mutating = Fix.spec do
  on(:push, 1) { it MUST eq [1] }
  on(:push, 2) { it MUST eq [2] }
  it MUST eq []
end
raise unless mutating.match? { [] }.equal?(true)
raise unless Fix.spec { it MUST eq 1 }.match? { 2 }.equal?(false)

# A specification is a matcher: fix(:Name) and fix { … } test the actual
# value against it.
Fix.spec(:FixTestInner) { it MUST be_a_kind_of Numeric }
outer = Fix.spec do
  it MUST fix(:FixTestInner)
  it MUST(fix { it MUST eq 1 })
end
raise unless outer.run { 1 }.map(&:outcome) == %i[success success]
raise unless outer.run do
  2
end.map(&:summary) == ["expected 2 to fix FixTestInner", "expected 2 to fix an anonymous specification"]
error = raised { Fix.spec { it MUST fix } }
raise unless error.instance_of?(ArgumentError) && error.message == "a name or a block must be given, not both"
error = raised { Fix.spec { it MUST fix(:FixTestInner) { nil } } }
raise unless error.instance_of?(ArgumentError) && error.message == "a name or a block must be given, not both"
error = raised { Fix.spec { it MUST fix(:FixTestMissing) } }
raise unless error.instance_of?(KeyError)

# The public surface of a specification: its two members, its three ways
# to test, its text, and nothing of the inside.
raise unless Fix::Spec.public_instance_methods(false).sort == %i[inspect match? name nodes run test to_s]
raise unless Fix.constants.sort == %i[Dsl Level Matcher Result Spec]
