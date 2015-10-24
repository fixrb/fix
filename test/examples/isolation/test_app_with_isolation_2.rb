unless Process.respond_to?(:fork)
  warn 'Info: fork is not implemented on the current platform.'
  exit
end

require_relative File.join '..', '..', 'support', 'coverage'
require_relative File.join '..', '..', '..', 'lib', 'fix'
require 'spectus'

@greeting = 'Hello, world!'

@spec = proc do
  context do
    on :gsub!, 'world', 'Alice' do
      it { MUST Eql: 'Hello, Alice!' }
    end
  end

  on :gsub!, 'world', 'Bob' do
    it { MUST Eql: 'Hello, Bob!' }
  end
end

t = Fix::Test.new(@greeting, color: false, verbose: false, &@spec)

Spectus.this { t.report.to_s }.MUST Eql:      \
  "Ran 2 tests in #{t.total_time} seconds\n"  \
  "100% compliant - 0 infos, 0 failures, 0 errors\n"

Spectus.this { t.pass? }.MUST :BeTrue
