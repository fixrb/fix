# frozen_string_literal: true

require_relative File.join("..", "..", "lib", "fix")

Fix :Duck do
  on :swims do
    it { MUST eql "Swoosh..." }
  end

  on :speaks do
    it { MUST raise_exception NoMethodError }
  end

  on :sings do
    it { MAY eql "♪... ♫..." }
  end
end
