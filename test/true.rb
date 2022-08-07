# frozen_string_literal: true

require_relative File.join("..", "fix", "true")

Fix[:True].test { true && boolean }
