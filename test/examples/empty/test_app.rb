require_relative File.join '..', '..', 'support', 'coverage'
require_relative File.join '..', '..', '..', 'lib', 'fix'
require 'spectus'

@app = nil

t = Fix::Test.new @app do
  # empty
end

Spectus.this { t.report.to_s }.MUST Eql:                      \
  "Ran 0 tests in #{t.total_time} seconds\n"                  \
  "\e[32m100% compliant - 0 infos, 0 failures, 0 errors\e[0m" \

Spectus.this { t.pass? }.MUST :BeTrue
Spectus.this { t.fail? }.MUST :BeFalse
