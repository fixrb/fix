# frozen_string_literal: true

require_relative File.join("..", "lib", "fix")

Fix :ItWithABlock do
  it MUST_NOT be 4
  it { MUST_NOT be 4 }

  it MUST be 42
  it { MUST be 42 }

  on :-, 42 do
    it MUST be 0

    it { MUST be 0 }
  end
end
