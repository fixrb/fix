require_relative File.join '..', '..', 'support', 'coverage'
require_relative File.join '..', '..', '..', 'lib', 'fix'
require 'spectus'

@greeting = 'Hello, world!'

@spec = proc do
  on :gsub!, 'world', 'Alice' do
    it { MUST! Eql: 'Hello, Alice!' }
  end

  context do
    on :gsub!, 'world', 'Bob' do
      it { MUST Eql: 'Hello, Bob!' }
    end
  end
end

t = Fix::Test.new(@greeting, color: false, verbose: false, &@spec)

Spectus.this { t.pass? }.MUST :BeTrue
