# frozen_string_literal: true

require_relative File.join("..", "fix", "true")

Fix[:True].against { true && boolean }
