# frozen_string_literal: true

require_relative File.join("..", "..", "lib", "fix")

Fix :Duck do
  let(:name) { "Bob" }

  it SHOULD be_an_instance_of :Duck

  on :say_hi do
    let(:name) { "Picsou" }

    it MUST eq "Hi, my name is Picsou!"
  end

  on :say_hi do
    with name: "Picsou" do
      it MUST eq "Hi, my name is Picsou!"
    end

    with name: "Donald" do
      it MUST eq "Hi, my name is Donald!"
    end
  end

  on :swims do
    it MUST be_an_instance_of :String
    it MUST eq "Swoosh..."

    on :length do
      it MUST be 9
    end
  end

  on :walks do
    on :length do
      it MUST be 10
    end
  end

  on :speaks do
    it MUST raise_exception NoMethodError
  end

  on :sings do
    it MAY eq "♪... ♫..."
  end

  on :quacks do
    it MUST be nil
  end
end
