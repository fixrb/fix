# frozen_string_literal: true

require_relative File.join '..', '..', 'support', 'coverage'
require_relative File.join '..', '..', '..', 'lib', 'fix'
require 'spectus'

include Spectus

it { Fix::It.new(4, [], {}).boom }.MUST raise_exception NoMethodError
it { Fix::It.new(4, [], boom: -> { 42 }).boom }.MUST equal 42
