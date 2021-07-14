# frozen_string_literal: true

require_relative "app"
require_relative "fix"

Fix[:Duck].call(Duck.new)
