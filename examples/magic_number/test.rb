# frozen_string_literal: true

require_relative "fix"

Fix[:MagicNumber].test { -42 }
