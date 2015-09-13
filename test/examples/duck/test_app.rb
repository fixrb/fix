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
    it { MUST Eql: 'Klop klop klop!' }
  end

  on :quacks do
    it { SHOULD :BeNil }
  end

  on :name do
    it { MUST Eql: 'Donald Fauntleroy Duck' }
  end
end

# Test without verbose option
t = Fix::Test.new(@bird, verbose: false, &@spec)

if defined?(RUBY_ENGINE) && RUBY_ENGINE == 'ruby' &&
   defined?(RUBY_VERSION) && RUBY_VERSION.start_with?('2.')

  Spectus.this { t.report.to_s }.MUST(Eql:                                    \
    "1. Info: undefined method `sings' for #{@bird} (NoMethodError).\n"       \
    "\n"                                                                      \
    "2. Failure: Expected \"Klop klop!\" to eql \"Klop klop klop!\".\n"       \
    "    #{t.report.test.results[3].backtrace.first}\n"                       \
    "\n"                                                                      \
    "3. Error: undefined method `name' for #{@bird} (NoMethodError).\n"       \
    "    #{t.report.test.results[-1].backtrace.first}\n"                      \
    "\n"                                                                      \
    "Ran 6 tests in #{t.total_time} seconds\n"                                \
    "67% compliant - 1 infos, 1 failures, 1 errors\n")
end

# Test with verbose option
t = Fix::Test.new(@bird, verbose: true, &@spec)

if defined?(RUBY_ENGINE) && RUBY_ENGINE == 'ruby' &&
   defined?(RUBY_VERSION) && RUBY_VERSION.start_with?('2.')

  Spectus.this { t.report.to_s }.MUST(Eql:                                    \
    "\n"                                                                      \
    "\n"                                                                      \
    "1. Info: undefined method `sings' for #{@bird} (NoMethodError).\n"       \
    "\n"                                                                      \
    "2. Failure: Expected \"Klop klop!\" to eql \"Klop klop klop!\".\n"       \
    "    #{t.report.test.results[3].backtrace.first}\n"                       \
    "\n"                                                                      \
    "3. Error: undefined method `name' for #{@bird} (NoMethodError).\n"       \
    "    #{t.report.test.results[-1].backtrace.first}\n"                      \
    "\n"                                                                      \
    "Ran 6 tests in #{t.total_time} seconds\n"                                \
    "67% compliant - 1 infos, 1 failures, 1 errors\n")
end

# Test with default verbose option
t = Fix::Test.new(@bird, &@spec)

if defined?(RUBY_ENGINE) && RUBY_ENGINE == 'ruby' &&
   defined?(RUBY_VERSION) && RUBY_VERSION.start_with?('2.')

  Spectus.this { t.report.to_s }.MUST(Eql:                                    \
    "\n"                                                                      \
    "\n"                                                                      \
    "1. Info: undefined method `sings' for #{@bird} (NoMethodError).\n"       \
    "\n"                                                                      \
    "2. Failure: Expected \"Klop klop!\" to eql \"Klop klop klop!\".\n"       \
    "    #{t.report.test.results[3].backtrace.first}\n"                       \
    "\n"                                                                      \
    "3. Error: undefined method `name' for #{@bird} (NoMethodError).\n"       \
    "    #{t.report.test.results[-1].backtrace.first}\n"                      \
    "\n"                                                                      \
    "Ran 6 tests in #{t.total_time} seconds\n"                                \
    "67% compliant - 1 infos, 1 failures, 1 errors\n")
end

# Test with color option
t = Fix::Test.new(@bird, color: true, &@spec)

if defined?(RUBY_ENGINE) && RUBY_ENGINE == 'ruby' &&
   defined?(RUBY_VERSION) && RUBY_VERSION.start_with?('2.')

  Spectus.this { t.report.to_s }.MUST(Eql:                                    \
    "\n"                                                                      \
    "\n"                                                                      \
    "\e[33m1. Info: undefined method `sings' for #{@bird} (NoMethodError).\n" \
    "\e[0m\n"                                                                 \
    "\e[35m2. Failure: Expected \"Klop klop!\" to eql \"Klop klop klop!\".\n" \
    "    #{t.report.test.results[3].backtrace.first}\n"                       \
    "\e[0m\n"                                                                 \
    "\e[31m3. Error: undefined method `name' for #{@bird} (NoMethodError).\n" \
    "    #{t.report.test.results[-1].backtrace.first}\n"                      \
    "\e[0m\n"                                                                 \
    "Ran 6 tests in #{t.total_time} seconds\n"                                \
    "\e[31m67% compliant - 1 infos, 1 failures, 1 errors\n"                   \
    "\e[0m")
end
