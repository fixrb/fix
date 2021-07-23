# frozen_string_literal: true

require_relative File.join("..", "..", "lib", "fix")

Fix :Duck do
  it SHOULD be_an_instance_of :Duck

  on :swims do
    it MUST be_an_instance_of :String
    it MUST eql "Swoosh..."
  end

  on :speaks, it(MUST(raise_exception(NoMethodError)))
  on :sings, it(MAY(eql "♪... ♫..."))
end
