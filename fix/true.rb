# frozen_string_literal: true

require_relative File.join("..", "lib", "fix")

Fix :True do
  let(:boolean) { true }

  it MUST_NOT be false
  it MUST be true

  on :! do
    it MUST be false
    it MUST_NOT be true
  end

  with boolean: true do
    it MUST be true
  end

  with boolean: false do
    it MUST be false
  end
end
