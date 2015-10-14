unless Process.respond_to?(:fork)
  warn 'Info: fork is not implemented on the current platform.'
  exit
end

require_relative File.join '..', '..', 'support', 'coverage'
require_relative File.join '..', '..', '..', 'lib', 'fix'
require 'spectus'

@greeting = 'Hello, world!'

@spec = proc do
  on :gsub!, 'world', 'Alice' do
    it { MUST! Eql: 'Hello, Alice!' }
    it { MUST Eql: 'Hello, Alice!' }
  end
end

t = Fix::Test.new(@greeting, color: false, verbose: false, &@spec)

Spectus.this { t.pass? }.MUST :BeTrue
