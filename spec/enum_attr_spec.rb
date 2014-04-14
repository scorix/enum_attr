require 'enum_attr'

describe 'enum_attr' do

  ##
  # test hash enum_attr
  #
  context 'hash enum attrs' do

    class TestHashWithoutDefaultClass
      enum_attr :sex, { male: 0, female: 1 }
    end

    subject { TestHashWithoutDefaultClass.new }

    it { should_not respond_to :set_default_sex }
    it { should respond_to :sex }
    it { should respond_to :sex= }
    its(:sex) { should be_nil }

    context 'change sex...' do
      before { subject.male! }
      its(:sex) { should eq 0 }
      its(:male?) { should be_true }
      its(:female?) { should be_false }
    end

  end

  ##
  # test hash enum_attr, specify a key as default value
  #
  context 'hash enum attrs with default value(by key)' do

    class TestHashWithDefaultClass1
      enum_attr :sex, { male: 0, female: 1 }, default: :male
    end

    subject { TestHashWithDefaultClass1.new }

    it { should respond_to :set_default_sex }
    it { should respond_to :sex }
    it { should respond_to :sex= }
    it { should be_male }

    context 'change sex...' do
      before { subject.female! }
      its(:sex) { should eq 1 }
      it { should be_female }
      its(:male?) { should be_false }
      its(:female?) { should be_true }
    end

  end

  ##
  # test hash enum_attr, specify a value as default value
  #
  context 'hash enum attrs with default value(by value)' do

    class TestHashWithDefaultClass2
      enum_attr :sex, { male: 0, female: 1 }, default: 1
    end

    subject { TestHashWithDefaultClass2.new }

    it { should respond_to :set_default_sex }
    it { should respond_to :sex }
    it { should respond_to :sex= }
    it { should be_female }

    context 'change sex...' do
      before { subject.male! }
      its(:sex) { should eq 0 }
      it { should be_male }
      its(:male?) { should be_true }
      its(:female?) { should be_false }
    end

  end

  ##
  # test array enum_attr
  #
  context 'array enum attrs without default value' do

    class TestArrayWithoutDefaultClass
      enum_attr :sex, [0, 1]
    end

    subject { TestArrayWithoutDefaultClass.new }

    it { should_not respond_to :set_default_sex }
    it { should respond_to :sex }
    it { should respond_to :sex= }
    its(:sex) { should be_nil }

    context 'change sex...' do
      before { subject.sex = 1 }
      its(:sex) { should eq 1 }
    end

  end

  ##
  # test array enum_attr with a default value
  #
  context 'array enum attrs with default value, case 1' do

    class TestArrayWithDefaultClass1
      enum_attr :sex, [0, 1], default: 0
    end

    subject { TestArrayWithDefaultClass1.new }

    it { should respond_to :set_default_sex }
    it { should respond_to :sex }
    it { should respond_to :sex= }
    its(:sex) { should eq 0 }

    context 'change sex...' do
      before { subject.sex = 1 }
      its(:sex) { should eq 1 }
    end

  end

  ##
  # test array enum_attr with a default value
  #
  # this case is testing the default value is the real value, not index
  #
  context 'array enum attrs with default value, case 2' do

    class TestArrayWithDefaultClass2
      enum_attr :sex, [1, 0], default: 0
    end

    subject { TestArrayWithDefaultClass2.new }

    it { should respond_to :set_default_sex }
    it { should respond_to :sex }
    it { should respond_to :sex= }
    its(:sex) { should eq 0 }

    context 'change sex...' do
      before { subject.sex = 1 }
      its(:sex) { should eq 1 }
    end

  end

  ##
  # test enum_attr in a class which constructor method has arguments
  #
  context 'constructor method with arguments' do

    class TestConstructorMethodWithArgumentsClass
      attr_reader :name

      def initialize(name)
        @name = name
      end

      enum_attr :sex, [0, 1], default: 0
    end

    subject { TestConstructorMethodWithArgumentsClass.new('scorix') }

    it { should respond_to :set_default_sex }
    it { should respond_to :sex }
    it { should respond_to :sex= }
    its(:sex) { should eq 0 }
    its(:name) { should eq 'scorix' }

    context 'change sex...' do
      before { subject.sex = 1 }
      its(:sex) { should eq 1 }
    end

  end
end