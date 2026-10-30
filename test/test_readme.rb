# frozen_string_literal: true

require "open3"
require "rbconfig"
require "tmpdir"

require_relative File.join("support", "coverage")
require_relative File.join("..", "lib", "fix")

# Each Ruby example of the README is a file, named by its first line when it
# is a comment, run by this Ruby with the lib directory on its load path, in
# an empty directory, so that a location is the name of the file. What it
# writes on the standard output is the text block that follows it, when
# there is one, and nothing on the standard error; its status is 0 unless a
# failure or an error is written. An `# => value` comment is what the
# expression before it gives, written by inspect. Ruby 3.3 quotes a method
# name with a backquote where 3.4 uses a quote, and names a method in a
# backtrace without its class: the output is read as 3.4 writes it. The
# Gemfile excerpt is left out.
readme = File.read(File.join(__dir__, "..", "README.md"), encoding: Encoding::UTF_8)
examples = readme.scan(/^```ruby\n(.*?)^```\n(?:\n```text\n(.*?)^```\n)?/m)
examples.reject! { |code, _| code.include?("# Gemfile") }
raise if examples.empty?
lib = File.expand_path(File.join("..", "lib"), __dir__)
Dir.mktmpdir do |dir|
  examples.each do |code, text|
    name = code[/\A# (\S+\.rb)\n/, 1] || "example.rb"
    checked = code.gsub(/^(?<expression>.+?) # => (?<expected>.+)$/) do
      expression = Regexp.last_match[:expression]
      expected = Regexp.last_match[:expected]
      "__actual = (#{expression}).inspect; " \
        "raise(#{"#{expression.strip} gave ".inspect} + __actual) unless __actual == #{expected.inspect}"
    end
    File.write(File.join(dir, name), checked)
    output, error, status = Open3.capture3(RbConfig.ruby, "-w", "-I", lib, name, chdir: dir)
    raise "#{name}: #{error}" unless error.empty?

    output = output.tr("`", "'")
    text = text.to_s
    text = text.gsub(/in '[A-Z][\w:]*[#.](?=\w+')/, "in '") if RUBY_VERSION.start_with?("3.3.")
    raise "#{name} wrote:\n#{output}" unless output == text
    raise "#{name} exited #{status.exitstatus}" unless status.exitstatus == (text.match?(/: (Failure|Error): /) ? 1 : 0)
  end
end
