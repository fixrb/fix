require_relative File.join 'support', 'coverage'
require_relative File.join '..', 'lib', 'fix'
require 'spectus'

Spectus.this { Fix::It.new(4, [], {}).boom }.MUST RaiseException: NoMethodError
Spectus.this { Fix::It.new(4, [], boom: -> { 42 }).boom }.MUST Equal: 42
