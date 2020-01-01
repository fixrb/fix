# frozen_string_literal: true

require 'simplecov'
require_relative 'app'
require_relative '../../lib/fix'

bird = Duck.new

Fix(bird) do
  on :swims do
    it { MUST eql 'Swoosh...' }
  end

  on :speaks do
    it { MUST raise_exception NoMethodError }
  end

  on :sings do
    it { MAY eql '♪... ♫...' }
  end
end
