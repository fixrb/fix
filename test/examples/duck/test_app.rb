# Encoding: utf-8

require_relative File.join '..', '..', 'support', 'coverage'
require_relative 'app'
require_relative File.join '..', '..', '..', 'lib', 'fix'
require 'spectus'

@bird = Duck.new

t = Fix::Test.new @bird do
  on :swims do
    it { MUST Eql: 'Swoosh...' }
  end

  on :speaks do
    it { MUST RaiseException: NoMethodError }
  end

  on :sings do
    it { MAY(Eql: '♪... ♫...') }
  end

  on :walks do
    it { SHOULD Eql: 'Klop klop!' }
  end

  on :quacks do
    it { SHOULD :BeNil }
  end

  on :full_name do
    it { MUST Eql: 'Donald Fauntleroy Duck' }
  end
end

if defined?(RUBY_ENGINE) && RUBY_ENGINE == 'ruby' &&
   defined?(RUBY_VERSION) && RUBY_VERSION.start_with?('2.')

  Spectus.this { t.report.to_s }.MUST(Eql:                                    \
    "\n"                                                                      \
    "\n"                                                                      \
    "1. Info: undefined method `sings' for #{@bird} (NoMethodError).\n"       \
    "\n"                                                                      \
    "2. Error: undefined method `full_name' for #{@bird} (NoMethodError).\n"  \
    "    #{t.report.test.results.last.backtrace.first}\n"                     \
    "\n"                                                                      \
    "Ran 6 tests in #{t.total_time} seconds\n"                                \
    "83% compliant - 1 infos, 0 failures, 1 errors\n")
end
