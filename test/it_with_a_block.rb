# frozen_string_literal: true

require_relative File.join("..", "fix", "it_with_a_block")

Fix[:ItWithABlock].test { 42 }
