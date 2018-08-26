# frozen_string_literal: false

unless Process.respond_to?(:fork)
  warn 'Info: fork is not implemented on the current platform.'
  exit
end

require_relative File.join '..', '..', 'support', 'coverage'
require_relative File.join '..', '..', '..', 'lib', 'fix'
require 'spectus'

include Spectus

@greeting = 'Hello, world!'

@spec = proc do
  on :gsub!, 'world', 'Alice' do
    it { MUST! eql 'Hello, Alice!' }
  end

  on :gsub!, 'world', 'Bob' do
    it { MUST eql 'Hello, Bob!' }
  end
end

t = Fix::Test.new(@greeting, color: false, verbose: false, &@spec)

it { t.report.to_s }.MUST eql                 \
  "Ran 2 tests in #{t.total_time} seconds\n"  \
  "100% compliant - 0 infos, 0 failures, 0 errors\n"

it { t.pass? }.MUST be_true
