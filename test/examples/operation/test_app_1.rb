require_relative File.join '..', '..', 'support', 'coverage'
require_relative File.join '..', '..', '..', 'lib', 'fix'
require 'spectus'

@app = 1_040
@spec = proc do
  on :+, 1_040 do
    it { MUST Equal: 2_080 }

    on(:+, 10) do
      it { MUST Equal: 2_090 }

      on(:+, 10) do
        it { MUST_NOT Equal: 3_000 }
        it { SHOULD Equal: 42 }
      end
    end
  end
end

# without color
t = Fix::Test.new(@app, color: false, verbose: false, &@spec)

Spectus.this { t.report.to_s }.MUST Eql:      \
  "1. Info: Expected 2100 to equal 42.\n"     \
  "\n"                                        \
  "Ran 4 tests in #{t.total_time} seconds\n"  \
  '100% compliant - 1 infos, 0 failures, 0 errors'

Spectus.this { t.pass? }.MUST :BeTrue
Spectus.this { t.fail? }.MUST :BeFalse

# with color
t = Fix::Test.new(@app, verbose: false, &@spec)

Spectus.this { t.report.to_s }.MUST Eql:        \
  "\e[33m1. Info: Expected 2100 to equal 42.\n" \
  "\e[0m\n"                                     \
  "Ran 4 tests in #{t.total_time} seconds\n"    \
  "\e[33m100% compliant - 1 infos, 0 failures, 0 errors\e[0m"

Spectus.this { t.pass? }.MUST :BeTrue
Spectus.this { t.fail? }.MUST :BeFalse
