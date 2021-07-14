# frozen_string_literal: true

require_relative File.join("..", "..", "lib", "fix")

Fix "EmptyString" do
  on :to_s do
    let(:r) { "foo" }

    on :+, "foo" do
      it { MUST eql r }
    end
  end

  on :to_s do
    on :+, "foo" do
      it { MUST eql "foo" }
    end
  end

  on :+, "bar" do
    it { SHOULD eql "foobar" }
  end

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

  on :+, "1" do
    it { SHOULD eql "foobar" }

    on :+, "1" do
      it { SHOULD eql "foobar" }

      on :+, "1" do
        it { SHOULD eql "foobar" }

        on :+, "1" do
          it { SHOULD eql "foobar" }
        end

        on :+, "1" do
          it { SHOULD eql "foobar once again" }
        end
      end
    end
  end
end
