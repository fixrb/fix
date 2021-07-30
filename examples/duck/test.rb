# frozen_string_literal: true

require_relative "app"
require_relative "fix"

Fix[:Duck].against do
  Duck.new(name)
end
