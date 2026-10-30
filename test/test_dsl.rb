# frozen_string_literal: true

require_relative File.join("support", "coverage")
require_relative File.join("..", "lib", "fix")
require_relative File.join("support", "helpers")

# A specification is a list of contexts, each before its children, holding
# its lets, its chain and its expectations in the order written.
line = __LINE__
spec = Fix.spec do
  let(:name) { "Bob" }
  it MUST eq "a"
  on :upcase do
    it MUST eq "b"
    with(name: "Alice") { it MUST eq "c" }
  end
  it MUST eq "d"
  on(:+, 2, key: 1) { it MUST eq "e" }
end
nodes = spec.nodes
raise unless nodes.size == 4 && nodes.frozen?
root, upcase, alice, plus = nodes
raise unless root.lets.keys == [:name] && root.lets.frozen? && root.challenges == [] && root.chain == ""
raise unless root.expectations.map { |e| e.requirement.matcher.to_s } == ['eq "a"', 'eq "d"']
raise unless root.expectations.frozen? && root.expectations.first.location == "test/test_dsl.rb:#{line + 3}"
raise unless root.expectations.first.location.frozen? && root.chain.frozen?
raise unless upcase.chain == ".upcase" && upcase.challenges.map(&:name) == [:upcase] && upcase.lets.equal?(root.lets)
raise unless upcase.expectations.map(&:location) == ["test/test_dsl.rb:#{line + 5}"]
raise unless alice.chain == ".upcase" && alice.lets[:name].call == "Alice" && alice.lets.keys == [:name]
raise unless alice.lets.frozen?
raise unless alice.expectations.first.requirement.matcher.to_s == 'eq "c"'
raise unless plus.chain == ".+(2, key: 1)" && plus.challenges.map(&:name) == [:+] && plus.expectations.size == 1
raise unless plus.challenges.frozen? && plus.chain.frozen? && plus.expectations.first.requirement.level == :MUST
raise unless spec.nodes.map { |node| node.expectations.size } == [2, 1, 1, 1]

# A context without an expectation is a node too, and the chain of nested
# on is the whole path.
empty = Fix.spec { on(:a) { on(:b, "x") { it MUST eq 1 } } }
raise unless empty.nodes.map(&:chain) == ["", ".a", '.a.b("x")']
raise unless empty.nodes.map { |node| node.expectations.size } == [0, 0, 1]
raise unless empty.nodes.first.lets == {} && empty.nodes.first.lets.frozen? && empty.nodes.first.challenges.frozen?

# A let is a parameter of the subject: a child context may override it, a
# with gives it a value, and a context cannot declare it twice.
overriding = Fix.spec do
  let(:name) { "Bob" }
  on(:a) { let(:name) { "Alice" } }
  with(name: "Carol") { nil }
end
raise unless overriding.nodes.map { |node| node.lets[:name].call } == %w[Bob Alice Carol]
error = raised { Fix.spec { let(:name) { 1 }; let(:name) { 2 } } } # rubocop:disable Style/Semicolon
raise unless error.instance_of?(ArgumentError) && error.message == "name is already a let of this context"
error = raised { Fix.spec { let("name") { 1 } } }
raise unless error.instance_of?(ArgumentError) && error.message == "the name of a let must be a Symbol"
error = raised { Fix.spec { let(:name) } }
raise unless error.instance_of?(ArgumentError) && error.message == "a block must be given"
error = raised { Fix.spec { with("name" => 1) { nil } } }
raise unless error.instance_of?(ArgumentError) && error.message == "the name of a let must be a Symbol"
error = raised { Fix.spec { with { nil } } }
raise unless error.instance_of?(ArgumentError) && error.message == "a with gives a value to a let: with(name: 1)"
error = raised { Fix.spec { with(name: 1) { let(:name) { 2 } } } }
raise unless error.instance_of?(ArgumentError) && error.message == "name is already a let of this context"
raise unless Fix.spec { with(name: 1) { on(:a) { let(:name) { 2 } } } }.nodes.last.lets[:name].call == 2

# A let cannot be named after a method of the environment, of the language,
# or a word of the language: nothing is redefined in silence. A with has
# the same rule.
def top_level_helper = 1
{
  class:            "class is already a method of Kernel",
  freeze:           "freeze is already a method of Kernel",
  method:           "method is already a method of Kernel",
  format:           "format is already a method of Kernel",
  test:             "test is already a method of Kernel",
  p:                "p is already a method of Kernel",
  initialize:       "initialize is already a method of Fix::Environment",
  top_level_helper: "top_level_helper is already a method of Object",
  eq:               "eq is already a method of Fix::Matcher",
  MUST:             "MUST is already a method of Fix::Level",
  it:               "it is a word of the specification language",
  let:              "let is a word of the specification language",
  with:             "with is a word of the specification language",
  on:               "on is a word of the specification language"
}.each do |name, message|
  error = raised { Fix.spec { let(name) { 1 } } }
  raise name.to_s unless error.instance_of?(ArgumentError) && error.message == message
  error = raised { Fix.spec { with(name => 1) { nil } } }
  raise name.to_s unless error.instance_of?(ArgumentError) && error.message == message
end
raise unless Fix.spec { let(:name) { 1 } }.nodes.first.lets.key?(:name)
raise unless Fix.spec { let(:items) { [] } }.nodes.first.lets.key?(:items)
# A private method of the language is not a method of the environment: the
# name is free.
raise unless Fix.spec { let(:context) { 1 } }.nodes.first.lets.key?(:context)
error = raised { Fix.spec { let(:nodes) { 1 } } }
raise unless error.instance_of?(ArgumentError) && error.message == "nodes is already a method of Fix::Dsl"

# A let named in an expectation is a mistake, with the remedy; a let
# declared after the expectation is an ordinary NameError; a word that is
# neither is an ordinary NoMethodError.
error = raised { Fix.spec { let(:name) { "Bob" }; it MUST eq name } } # rubocop:disable Style/Semicolon
raise unless error.instance_of?(NameError) && error.name == :name
raise unless error.message.start_with?("name is a let, visible in the subject block and in other lets only")
error = raised { Fix.spec { let(:name) { "Bob" }; with(label: name) { nil } } } # rubocop:disable Style/Semicolon
raise unless error.instance_of?(NameError) && error.message.start_with?("name is a let")
error = raised { Fix.spec { on(:a) { let(:inner) { 1 } }; it MUST eq inner } } # rubocop:disable Style/Semicolon
raise unless error.instance_of?(NameError) && error.message.start_with?("undefined local variable or method")
error = raised { Fix.spec { it MUST eq nmae } }
raise unless error.instance_of?(NameError) && !error.message.include?("is a let")
error = raised { Fix.spec { bogus(1) } }
raise unless error.instance_of?(NoMethodError)
raise if Fix::Dsl.new({}.freeze, [].freeze, "").respond_to?(:name)

# with and on need a block; it needs a requirement, and no block.
error = raised { Fix.spec { with(name: 1) } }
raise unless error.instance_of?(ArgumentError) && error.message == "a block must be given"
error = raised { Fix.spec { on(:a) } }
raise unless error.instance_of?(ArgumentError) && error.message == "a block must be given"
error = raised { Fix.spec { on("a") { nil } } }
raise unless error.instance_of?(ArgumentError) && error.message == "the name of the method must be a Symbol"
error = raised { Fix.spec { self.it } }
raise unless error.instance_of?(ArgumentError) && error.message == "it takes a requirement: it MUST eq(1)"
error = raised { Fix.spec { it(eq(1)) } }
raise unless error.instance_of?(ArgumentError) && error.message == "it takes a requirement: it MUST eq(1)"
error = raised { Fix.spec { it { MUST eq 1 } } }
raise unless error.instance_of?(ArgumentError) && error.message == "it takes a requirement, not a block: it MUST eq(1)"
bad = Object.new
def bad.match? = true
def bad.to_s = 42
error = raised { Fix.spec { it MUST bad } }
raise unless error.instance_of?(TypeError) && error.message == "the to_s of the matcher must be a String"

# The location is the caller of it, relative to the current directory when
# under it, or the one given by a word that composes it.
somewhere = caller_locations(0, 1).fetch(0)
given = Fix.spec { it MUST(eq(1)), location: somewhere }
raise unless given.nodes.first.expectations.first.location == "test/test_dsl.rb:#{somewhere.lineno}"
outside = Struct.new(:path, :lineno).new("/elsewhere/spec.rb", 7)
elsewhere = Fix.spec { it MUST(eq(1)), location: outside }
raise unless elsewhere.nodes.first.expectations.first.location == "/elsewhere/spec.rb:7"
relative = Struct.new(:path, :lineno).new("test/x.rb", 2)
raise unless Fix.spec { it MUST(eq(1)), location: relative }.nodes.first.expectations.first.location == "test/x.rb:2"
# A path is taken as it is: no home directory in a tilde, and a byte that is
# not UTF-8 is replaced, as is one in the chain.
tilde = Struct.new(:path, :lineno).new("~x.rb", 3)
raise unless Fix.spec { it MUST(eq(1)), location: tilde }.nodes.first.expectations.first.location == "~x.rb:3"
bytes = Struct.new(:path, :lineno).new("bad\xFF.rb".b, 4)
scrubbed = Fix.spec { it MUST(eq(1)), location: bytes }.nodes.first.expectations.first.location
raise unless scrubbed == "bad\uFFFD.rb:4" && scrubbed.encoding == Encoding::UTF_8
invalid = Struct.new(:path, :lineno).new("bad\xFF.rb".dup.force_encoding(Encoding::UTF_8), 5)
raise unless Fix.spec { it MUST(eq(1)), location: invalid }.nodes.first.expectations.first.location == "bad\uFFFD.rb:5"
binary = Object.new
def binary.inspect = "\xFF".b
raise unless Fix.spec { on(:m, binary) { nil } }.nodes.last.chain == ".m(\uFFFD)"
# Under the root directory, everything is relative.
absolute = Struct.new(:path, :lineno).new("/a/b.rb", 5)
rooted = Aw.fork! do
  Dir.chdir("/") # rubocop:disable ThreadSafety/DirChdir
  Fix.spec { it MUST(eq(1)), location: absolute }.nodes.first.expectations.first.location
end
raise unless rooted == "a/b.rb:5"

# The text of the chain is written when on is defined, by the inspect of
# the arguments: it runs once, there.
counted = Object.new
count = 0
counted.define_singleton_method(:inspect) { "counted #{count += 1}" }
chained = Fix.spec { on(:m, counted) { it MUST eq 1 } }
raise unless chained.nodes.last.chain == ".m(counted 1)" && count == 1

# The four words are the public methods of the language, with the levels
# and the matchers; the rest is private.
raise unless Fix::Dsl.public_instance_methods(false).sort == %i[it let nodes on with]
raise unless Fix::Dsl.constants.empty?

# Dsl is public: a word that composes on and it can be added to it, and
# nodes, read in the middle of a document, gives it as it stands.
Fix::Dsl.class_eval do
  def its(method, &)
    location = caller_locations(1, 1).fetch(0)
    on(method) { it(instance_exec(&), location:) }
  end

  def written = nodes.first.expectations.size
end
begin
  extended = Fix.spec { its(:size) { MUST eq 3 } }
  raise unless extended.nodes.last.chain == ".size"
  raise unless extended.nodes.last.expectations.first.location == "test/test_dsl.rb:#{__LINE__ - 2}"
  counted = Fix.spec { it MUST eq 1; raise unless written == 1; it MUST eq 2 } # rubocop:disable Style/Semicolon
  raise unless counted.nodes.first.expectations.size == 2
ensure
  Fix::Dsl.send(:remove_method, :its)
  Fix::Dsl.send(:remove_method, :written)
end
