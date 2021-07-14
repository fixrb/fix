require_relative "lib/fix"

require "byebug"

d = Fix :MyTest do
  it { MUST eql "#{foo}FOO" }

  let(:foo) { "FOO" }

  on :downcase do
    let(:bar) { "BAR" }
    it { MUST eql "foofoo" }
  end

  it { MUST eql "FOOFOO" }
end

# d.call("FOOFOO")

Fix[:MyTest].call("FOOFOO")
