# Encoding: utf-8

require_relative File.join '..', '..', 'support', 'coverage'
require_relative 'app'
require_relative File.join '..', '..', '..', 'lib', 'fix'
require 'spectus'

@bird = Duck.new
@spec = proc do
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

# Test without verbose option
t1 = Fix::Test.new(@bird, verbose: false, &@spec)

if defined?(RUBY_ENGINE) && RUBY_ENGINE == 'ruby' &&
   defined?(RUBY_VERSION) && RUBY_VERSION.start_with?('2.')

  Spectus.this { t1.report.to_s }.MUST(Eql:                                   \
    "1. Info: undefined method `sings' for #{@bird} (NoMethodError).\n"       \
    "\n"                                                                      \
    "2. Error: undefined method `full_name' for #{@bird} (NoMethodError).\n"  \
    "    #{t1.report.test.results.last.backtrace.first}\n"                    \
    "\n"                                                                      \
    "Ran 6 tests in #{t1.total_time} seconds\n"                               \
    "83% compliant - 1 infos, 0 failures, 1 errors\n")
end

# Test with verbose option
t2 = Fix::Test.new(@bird, verbose: true, &@spec)

if defined?(RUBY_ENGINE) && RUBY_ENGINE == 'ruby' &&
   defined?(RUBY_VERSION) && RUBY_VERSION.start_with?('2.')

  Spectus.this { t2.report.to_s }.MUST(Eql:                                   \
    "\n"                                                                      \
    "\n"                                                                      \
    "1. Info: undefined method `sings' for #{@bird} (NoMethodError).\n"       \
    "\n"                                                                      \
    "2. Error: undefined method `full_name' for #{@bird} (NoMethodError).\n"  \
    "    #{t2.report.test.results.last.backtrace.first}\n"                    \
    "\n"                                                                      \
    "Ran 6 tests in #{t2.total_time} seconds\n"                               \
    "83% compliant - 1 infos, 0 failures, 1 errors\n")
end

# Test with default verbose option
t3 = Fix::Test.new(@bird, &@spec)

if defined?(RUBY_ENGINE) && RUBY_ENGINE == 'ruby' &&
   defined?(RUBY_VERSION) && RUBY_VERSION.start_with?('2.')

  Spectus.this { t3.report.to_s }.MUST(Eql:                                   \
    "\n"                                                                      \
    "\n"                                                                      \
    "1. Info: undefined method `sings' for #{@bird} (NoMethodError).\n"       \
    "\n"                                                                      \
    "2. Error: undefined method `full_name' for #{@bird} (NoMethodError).\n"  \
    "    #{t3.report.test.results.last.backtrace.first}\n"                    \
    "\n"                                                                      \
    "Ran 6 tests in #{t3.total_time} seconds\n"                               \
    "83% compliant - 1 infos, 0 failures, 1 errors\n")
end
