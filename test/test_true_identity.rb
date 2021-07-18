# frozen_string_literal: true

require_relative File.join("..", "lib", "fix")

Fix { it MUST_NOT equal true }.test { false }
