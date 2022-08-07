# frozen_string_literal: true

require_relative File.join("..", "..", "..", "lib", "fix")

Fix { it MUST raise_exception(NameError) }.test { Fix::Boom! }

# test/matcher/expecting_errors/raise_exception_spec.rb:5 Success: undefined method `Boom!' for Fix:Module.
