# frozen_string_literal: true

require "fileutils"
require "simplecov"

SimpleCov.start do
  # Leave the test directory out of the report.
  skip "/test/"
  enable_coverage :branch
  # The tests of a spec run in a child of Aw: merge the share of every child.
  merge_subprocesses true
  minimum_coverage line: 100, branch: 100
end

# Start from an empty resultset: SimpleCov merges the results of the last
# ten minutes, and a previous run would cover for a child that stored
# nothing in this one.
FileUtils.rm_f(File.join(SimpleCov.coverage_path, ".resultset.json"))

# A child stores its share from an at_exit handler, which the exit! ending
# every child of Aw skips: store it just before. Loaded before Aw, so that
# the exit! Aw captures is this one. It calls the original directly, not
# through super, so a block that redefines exit! does not change it.
exit_bang = Process.method(:exit!)
Process.singleton_class.prepend(
  Module.new do
    define_method(:exit!) do |status = false|
      SimpleCov.result
    ensure
      exit_bang.call(status)
    end
  end
)
