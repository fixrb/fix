require_relative File.join '..', '..', 'support', 'coverage'
require_relative File.join '..', '..', '..', 'lib', 'fix'
require 'spectus'

@greeting = 'Hello, world!'

@spec = proc do
  on :gsub!, 'world', 'Alice' do
    it { MUST Eql: 'Hello, Alice!' }
  end

  on :gsub!, 'world', 'Bob' do
    it { MUST Eql: 'Hello, Bob!' }
  end
end

t = Fix::Test.new(@greeting, color: false, verbose: false, &@spec)

Spectus.this { t.report.to_s }.MUST Eql:                \
  "1. Failure: Expected nil to eql \"Hello, Bob!\".\n"  \
  "    #{t.report.test.results[1].backtrace.first}\n"   \
  "\n"                                                  \
  "Ran 2 tests in #{t.total_time} seconds\n"            \
  "50% compliant - 0 infos, 1 failures, 0 errors\n"

Spectus.this { t.pass? }.MUST :BeFalse
