# frozen_string_literal: true

SimpleCov.command_name "Fix"

SimpleCov.start do
  add_filter "/examples/duck/app.rb"
end
