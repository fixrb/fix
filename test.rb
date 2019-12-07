# frozen_string_literal: true

require 'fix'

Fix(-42) do
  on :-, 1 do
    it { MUST equal -43 }

    on :-, 1 do
      it { MUST equal -44 }

      with zero: 0 do
        let(:trois) { 3 + zero }
        on :-, trois do
          it { MUST equal -47 }
        end
      end
    end
  end

  let(:foo) { 'FOO' }

  it { MUST equal -42 }
  it { MUST equal -42 }

  on :abs do
    before do
      # puts "      inside the on :abs, we can access :foo -> #{foo.inspect}"
    end

    let(:zero) { 0 }
    let(:nb_42) { 42 - zero }

    it { MUST equal nb_42 }

    on :to_s do
      on :length do
        it { MUST equal 2 }
      end

      it { MUST eql '42' }
    end

    let(:nb_21) { 21 }

    # on :/, 0 do
    #   it { MUST equal nb_21.next }
    #
    #   it { MUST raise_exception(ZeroDivisionError) }
    #
    #   # on :+, 100 do
    #   #   it { MUST equal 121.next }
    #   # end
    # end
  end

  it { MUST equal -42 }

  # let!(:boom) do
  #   module Fix
  #     class Context
  #       def it(*, **, &block)
  #         true
  #       end
  #     end
  #   end
  # end

  # let(:boom) do
  #   exit 0
  # end

  # let(:it) { puts 'bad'; 40 }
  # let(:nil) { puts 'bad'; 40 }
  # let(:true) { puts 'bad'; 40 }
  # let(:false) { puts 'bad'; 40 }
  # let(:Fix) { puts 'bad'; 40 }
  # let(:exit) {}

  # byebug

  before do
    # puts "BIG SIDE-EFFECT!!!!"
  end

  before do
    # puts "BIG SIDE-EFFECT!!!!!!!!! (2)"
  end

  after do
    # puts "END"
  end

  it { MUST equal -42 }

  let(:number1) { 40 }
  let(:'number1') { number1 + 2 }
  #
  let(:zero) { 0 }
  #
  let(:foo?) { 'FOO!' }
  #
  it { MUST_NOT equal number1 }
  it { MUST_NOT equal number1 }
  it { SHOULD equal -1 }
  it { MAY equal -1 }

  on :boom do
    it { MAY equal -1 }
    it { SHOULD equal -1 }
  end

  with number2: number1 + 1 + zero do
    # let(:number2) { number1 + 1 }

    it { MUST equal -number2.next + zero + (2) }

    # let's redefine the number1
    let(:number1) { 1 }

    it { MUST_NOT equal number1 }

    it "verifies foo? == 'FOO!'" do
      # foo? == 'FOO!'
      MUST_NOT eql foo?
    end

    # let's redefine the number2
    let(:number2) { 2 }

    it "verifies number2 == 2" do
      # number2 == 2
      MUST_NOT eql number2.next
    end
  end

  on :+, 1 do
    # subject { 1 }
    it { SHOULD equal 1 }
  end

  on :+, 1 do
    # subject { 1 }

    on :+, 1 do
      it { SHOULD equal 1 }
    end
  end

  on :lol, 1 do
    # subject { nil + 1 }

    it { MUST raise_exception NoMethodError }

    on :class do
      it { MUST equal NoMethodError }
    end

    on :respond_to?, :message do
      it { MUST be_true }
    end

    on :call, 1 do
      it { MAY equal 1 }
    end
  end

  # on :+, 1 do
  #   it { SHOULD equal @subject.call }
  # end

  # ---

  on :-, 1 do
    it { SHOULD eql -43 }

    on :-, 1 do
      it { SHOULD eql -44 }

      on :-, 1 do
        it { SHOULD eql -45 }
      end
    end
  end
end


Fix('foo') do
  on :+, 'bar' do
    it { SHOULD eql 'foobar' }
  end
end


Fix('foo') do
  on :lol, 'bar' do
    it { SHOULD eql 'foobar' }

    on :dddd, 'bar' do
      it { SHOULD eql 'foobar' }

      on :dd, 'bar' do
        it { SHOULD eql 'foobar' }

        on :d, 'bar' do
          it { SHOULD eql 'foobar' }
        end
      end
    end
  end
end

Fix('foo') do
  on :+, '1' do
    before do
      puts 's'
    end

    # it { :lol }
    it { SHOULD eql 'foobar' }

    on :+, '1' do
      it { SHOULD eql 'foobar' }

      on :+, '1' do
        it { SHOULD eql 'foobar' }

        on :+, '1' do
          before { warn "ss" }
          it { SHOULD eql 'foobar' }
        end

        on :+, '1' do
          it { SHOULD eql 'foobar encore' }
        end
      end
    end
  end
end
