require_relative File.join 'support', 'coverage'
require_relative File.join '..', 'lib', 'fix'
require 'spectus'

include Spectus

begin
  Fix.describe 4, verbose: false do
    it { MUST equal 42 }
  end
rescue SystemExit => e
  it { e.success? }.MUST be_false
end

begin
  Fix.describe 42, verbose: false do
    it { MUST equal 42 }
  end
rescue SystemExit => e
  it { e.success? }.MUST be_true
end
