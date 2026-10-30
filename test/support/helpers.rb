# frozen_string_literal: true

require "stringio"

# The exception a block raises, or nil.
def raised
  yield
  nil
rescue Exception => e # rubocop:disable Lint/RescueException
  e
end

# The value of a block and what it wrote on the standard output.
def printed
  stdout = $stdout
  $stdout = StringIO.new
  value = yield
  [value, $stdout.string]
ensure
  $stdout = stdout
end
