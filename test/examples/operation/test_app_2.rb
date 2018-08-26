# frozen_string_literal: true

require_relative File.join '..', '..', 'support', 'coverage'
require_relative File.join '..', '..', '..', 'lib', 'fix'
require 'spectus'

include Spectus

@app = 4
@spec = proc do
  it { MUST equal 42 }
end

t = Fix::Test.new(@app, verbose: false, &@spec)

it { t.report.to_s }.MUST eql                             \
  "\e[35m1. Failure: Expected 4 to equal 42.\n"           \
  "    #{t.report.test.results.first.backtrace.first}\n"  \
  "\e[0m\n"                                               \
  "Ran 1 tests in #{t.total_time} seconds\n"              \
  "\e[35m0% compliant - 0 infos, 1 failures, 0 errors\n"  \
  "\e[0m"

it { t.pass? }.MUST be_false
it { t.fail? }.MUST be_true
