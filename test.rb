# frozen_string_literal: true

require_relative "lib/fix"

require "byebug"

Fix :MyTest do
  it { MUST eql "#{foo}FOO" }

  let(:foo) { "FOO" }

  on :downcase do
    let(:bar) { "BAR" }
    it { MUST eql "foofoo" }
  end

  it { MUST eql "FOOFOO" }
end

Fix[:MyTest].call("FOOFOO")
