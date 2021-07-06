# frozen_string_literal: true

require "simplecov"
require_relative "../../lib/fix"

Fix do
  # let(:let) { 4 }

  on :to_s do
    let(:r) { "foo" }
    on :+, "foo" do
      it { MUST eql r }
    end
  end
end

Fix do
  on :to_s do
    on :+, "foo" do
      it { MUST eql "foo" }
    end
  end
end

Fix("foo") do
  on :+, "bar" do
    it { SHOULD eql "foobar" }
  end
end

Fix("foo") do
  on :ddd, "bar" do
    it { MAY eql "foobar" }

    on :dddd, "bar" do
      it { MAY eql "foobar" }

      on :dd, "bar" do
        it { MAY eql "foobar" }

        on :d, "bar" do
          it { MAY eql "foobar" }
        end
      end
    end
  end
end

Fix("foo") do
  on :+, "1" do
    before do
      puts "Let's start!"
    end

    it { SHOULD eql "foobar" }

    on :+, "1" do
      it { SHOULD eql "foobar" }

      on :+, "1" do
        it { SHOULD eql "foobar" }

        on :+, "1" do
          before { warn "starting!" }
          it { SHOULD eql "foobar" }
        end

        on :+, "1" do
          it { SHOULD eql "foobar once again" }
        end
      end
    end
  end
end
