# frozen_string_literal: true

require_relative File.join("..", "..", "lib", "fix")

Fix :MagicNumber do
  on :-, 1 do
    it MUST equal(-43)

    on :-, 1 do
      it MUST equal(-44)

      with zero: 0 do
        on :-, 3 do
          it MUST equal(-47)
        end
      end
    end
  end

  let(:foo) { "FOO" }

  it MUST equal(-42)
  it MUST equal(-42)

  on :abs do
    zero = 0
    nb42 = 42 - zero

    it MUST equal nb42

    on :to_s do
      on :length do
        it MUST equal 2
      end

      it MUST eql "42"
    end

    let(:nb21) { 21 }
  end

  it MUST equal(-423)
  it MUST equal(-42)

  number1 = 40
  # let(:number1) { number1 + 2 }

  foo = "FOO!"

  it MUST_NOT equal number1
  it MUST_NOT equal number1
  it SHOULD equal(-42)
  it MAY equal(-42)

  on :boom do
    it MAY equal(-1)
    it MAY equal(-42)
  end

  with number2: 41 do
    # let's redefine the number1
    let(:number1) { 1 }

    it MUST_NOT equal number1
    it MUST_NOT eql foo

    # let's redefine the number2
    number2 = 2

    it MUST_NOT eql number2.next
  end

  on :+, 1 do
    it SHOULD equal 1
  end

  on :+, 1 do
    on :+, 1 do
      it SHOULD equal 1
    end
  end

  on :lol, 1 do
    it MUST raise_exception NoMethodError

    on :class do
      it MUST raise_exception NoMethodError
    end

    on :respond_to?, :message do
      it MUST raise_exception NoMethodError
    end

    on :call, 1 do
      it MAY raise_exception NoMethodError
    end
  end

  on :-, 1 do
    it SHOULD eql(-43)

    on :-, 1 do
      it SHOULD eql(-44)

      on :-, 1 do
        it SHOULD eql(-45)
      end
    end
  end
end
