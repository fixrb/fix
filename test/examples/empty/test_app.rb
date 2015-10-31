require_relative File.join '..', '..', 'support', 'coverage'
require_relative File.join '..', '..', '..', 'lib', 'fix'
require 'spectus'

include Spectus

@app = nil

t = Fix::Test.new @app do
  # empty
end

it { t.report.to_s }.MUST eql                               \
  "Ran 0 tests in #{t.total_time} seconds\n"                \
  "\e[32m100% compliant - 0 infos, 0 failures, 0 errors\n"  \
  "\e[0m"

it { t.pass? }.MUST be_true
it { t.fail? }.MUST be_false
