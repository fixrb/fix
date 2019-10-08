# frozen_string_literal: false

require_relative File.join('..', '..', 'support', 'coverage')
require_relative File.join('..', '..', '..', 'lib', 'fix')
require 'spectus'

include Spectus

@greeting = 'Hello, world!'

@spec = proc do
  on :gsub!, 'world', 'Alice' do
    context do
      it { MUST eql 'Hello, Alice!' }
      it { MUST eql 'Hello, Alice!' }
    end
  end
end

t = Fix::Test.new(@greeting, color: false, verbose: false, &@spec)

it { t.report.to_s }.MUST eql                             \
  "1. Failure: Expected nil to eql \"Hello, Alice!\".\n"  \
  "    #{t.report.test.results[1].backtrace.first}\n"     \
  "\n"                                                    \
  "Ran 2 tests in #{t.total_time} seconds\n"              \
  "50% compliant - 0 infos, 1 failures, 0 errors\n"

it { t.pass? }.MUST be_false
