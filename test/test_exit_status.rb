# frozen_string_literal: true

require_relative File.join('support', 'coverage')
require_relative File.join('..', 'lib', 'fix')

begin
  Fix.describe(4, verbose: false) do
    it { MUST equal 42 }
  end
rescue SystemExit => e
  raise unless e.success? == false
end

begin
  Fix.describe(42, verbose: false) do
    it { MUST equal 42 }
  end
rescue SystemExit => e
  raise unless e.success? == true
end
