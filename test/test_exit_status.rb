require_relative File.join 'support', 'coverage'
require_relative File.join '..', 'lib', 'fix'
require 'spectus'

begin
  Fix.describe 4, verbose: false do
    it { MUST Equal: 42 }
  end
rescue SystemExit => e
  Spectus.this { e.success? }.MUST :BeFalse
end

begin
  Fix.describe 42, verbose: false do
    it { MUST Equal: 42 }
  end
rescue SystemExit => e
  Spectus.this { e.success? }.MUST :BeTrue
end
