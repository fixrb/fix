# frozen_string_literal: true

require_relative File.join '..', '..', 'support', 'coverage'
require_relative 'app'
require_relative File.join '..', '..', '..', 'lib', 'fix'
require 'spectus'

include Spectus

@bird = Duck.new
@spec = proc do
  let(:famous_word) { 'So!' }

  on :swims do
    it { MUST eql "#{famous_word} Swoosh..." }
  end

  on :speaks do
    it { MUST raise_exception NoMethodError }
  end

  on :sings do
    it 'May sings' do
      MAY eql '♪... ♫...'
    end
  end

  on :walks do
    it { MUST eql "#{famous_word} klop!" }
  end

  on :quacks do
    it { SHOULD be_nil }
  end

  on :name do
    it { MUST eql 'Donald Fauntleroy Duck' }
  end
end

# Test without verbose option
t = Fix::Test.new(@bird, color: false, verbose: false, &@spec)

if defined?(RUBY_ENGINE) && RUBY_ENGINE == 'ruby' &&
   defined?(RUBY_VERSION) && RUBY_VERSION.start_with?('2.')

  it { t.report.to_s }.MUST eql                                         \
    "1. Info: undefined method `sings' for #{@bird} (NoMethodError).\n" \
    "\n"                                                                \
    "2. Failure: Expected \"So! Klop klop!\" to eql \"So! klop!\".\n"   \
    "    #{t.report.test.results[3].backtrace.first}\n"                 \
    "\n"                                                                \
    "3. Error: undefined method `name' for #{@bird} (NoMethodError).\n" \
    "    #{t.report.test.results[-1].backtrace.first}\n"                \
    "\n"                                                                \
    "Ran 6 tests in #{t.total_time} seconds\n"                          \
    "67% compliant - 1 infos, 1 failures, 1 errors\n"
end

# Test with verbose option
t = Fix::Test.new(@bird, color: false, verbose: true, &@spec)

if defined?(RUBY_ENGINE) && RUBY_ENGINE == 'ruby' &&
   defined?(RUBY_VERSION) && RUBY_VERSION.start_with?('2.')

  it { t.report.to_s }.MUST eql                                         \
    "\n"                                                                \
    "\n"                                                                \
    "1. Info: undefined method `sings' for #{@bird} (NoMethodError).\n" \
    "\n"                                                                \
    "2. Failure: Expected \"So! Klop klop!\" to eql \"So! klop!\".\n"   \
    "    #{t.report.test.results[3].backtrace.first}\n"                 \
    "\n"                                                                \
    "3. Error: undefined method `name' for #{@bird} (NoMethodError).\n" \
    "    #{t.report.test.results[-1].backtrace.first}\n"                \
    "\n"                                                                \
    "Ran 6 tests in #{t.total_time} seconds\n"                          \
    "67% compliant - 1 infos, 1 failures, 1 errors\n"
end

# Test with default verbose option
t = Fix::Test.new(@bird, color: false, &@spec)

if defined?(RUBY_ENGINE) && RUBY_ENGINE == 'ruby' &&
   defined?(RUBY_VERSION) && RUBY_VERSION.start_with?('2.')

  it { t.report.to_s }.MUST eql                                         \
    "\n"                                                                \
    "\n"                                                                \
    "1. Info: undefined method `sings' for #{@bird} (NoMethodError).\n" \
    "\n"                                                                \
    "2. Failure: Expected \"So! Klop klop!\" to eql \"So! klop!\".\n"   \
    "    #{t.report.test.results[3].backtrace.first}\n"                 \
    "\n"                                                                \
    "3. Error: undefined method `name' for #{@bird} (NoMethodError).\n" \
    "    #{t.report.test.results[-1].backtrace.first}\n"                \
    "\n"                                                                \
    "Ran 6 tests in #{t.total_time} seconds\n"                          \
    "67% compliant - 1 infos, 1 failures, 1 errors\n"
end

# Test with color option
t = Fix::Test.new(@bird, &@spec)

if defined?(RUBY_ENGINE) && RUBY_ENGINE == 'ruby' &&
   defined?(RUBY_VERSION) && RUBY_VERSION.start_with?('2.')

  it { t.report.to_s }.MUST eql                                               \
    "\n"                                                                      \
    "\n"                                                                      \
    "\e[33m1. Info: undefined method `sings' for #{@bird} (NoMethodError).\n" \
    "\e[0m\n"                                                                 \
    "\e[35m2. Failure: Expected \"So! Klop klop!\" to eql \"So! klop!\".\n"   \
    "    #{t.report.test.results[3].backtrace.first}\n"                       \
    "\e[0m\n"                                                                 \
    "\e[31m3. Error: undefined method `name' for #{@bird} (NoMethodError).\n" \
    "    #{t.report.test.results[-1].backtrace.first}\n"                      \
    "\e[0m\n"                                                                 \
    "Ran 6 tests in #{t.total_time} seconds\n"                                \
    "\e[31m67% compliant - 1 infos, 1 failures, 1 errors\n"                   \
    "\e[0m"
end
