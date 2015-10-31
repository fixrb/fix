require_relative File.join '..', '..', 'support', 'coverage'
require_relative File.join '..', '..', '..', 'lib', 'fix'
require 'spectus'

include Spectus

@app = 1_040
@spec = proc do
  on :+, 1_040 do
    it { MUST equal 2_080 }

    on(:+, 10) do
      it { MUST equal 2_090 }

      on(:+, 10) do
        it { MUST_NOT equal 3_000 }
        it { SHOULD equal 42 }
      end
    end
  end
end

# without color
t = Fix::Test.new(@app, color: false, verbose: false, &@spec)

it { t.report.to_s }.MUST eql                 \
  "1. Info: Expected 2100 to equal 42.\n"     \
  "\n"                                        \
  "Ran 4 tests in #{t.total_time} seconds\n"  \
  "100% compliant - 1 infos, 0 failures, 0 errors\n"

it { t.pass? }.MUST be_true
it { t.fail? }.MUST be_false

# with color
t = Fix::Test.new(@app, verbose: false, &@spec)

it { t.report.to_s }.MUST eql                               \
  "\e[33m1. Info: Expected 2100 to equal 42.\n"             \
  "\e[0m\n"                                                 \
  "Ran 4 tests in #{t.total_time} seconds\n"                \
  "\e[33m100% compliant - 1 infos, 0 failures, 0 errors\n"  \
  "\e[0m"

it { t.pass? }.MUST be_true
it { t.fail? }.MUST be_false
