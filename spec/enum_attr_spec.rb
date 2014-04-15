require 'enum_attr'

describe 'enum_attr' do

  ##
  # test hash enum_attr
  #
  context 'hash enum attrs' do

    class TestHashWithoutDefaultClass
      include EnumAttr
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
      include EnumAttr
      enum_attr :sex, { male: 0, female: 1 }, default: :male
    end

    subject { TestHashWithDefaultClass1.new }

    it { should respond_to :set_default_sex }
    it { should respond_to :sex }
    it { should respond_to :sex= }
    it { should be_male }
    its(:available_sexes) { should eq male: 0, female: 1 }
    its('class.available_sexes') { should eq male: 0, female: 1 }

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
      include EnumAttr
      enum_attr :sex, { male: 0, female: 1 }, default: 1
    end

    subject { TestHashWithDefaultClass2.new }

    it { should respond_to :set_default_sex }
    it { should respond_to :sex }
    it { should respond_to :sex= }
    it { should be_female }
    its(:available_sexes) { should eq male: 0, female: 1 }
    its('class.available_sexes') { should eq male: 0, female: 1 }

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
      include EnumAttr
      enum_attr :sex, [0, 1]
    end

    subject { TestArrayWithoutDefaultClass.new }

    it { should_not respond_to :set_default_sex }
    it { should respond_to :sex }
    it { should respond_to :sex= }
    its(:sex) { should be_nil }
    its(:available_sexes) { should eq [0, 1] }
    its('class.available_sexes') { should eq [0, 1] }

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
      include EnumAttr
      enum_attr :sex, [0, 1], default: 0
    end

    subject { TestArrayWithDefaultClass1.new }

    it { should respond_to :set_default_sex }
    it { should respond_to :sex }
    it { should respond_to :sex= }
    its(:sex) { should eq 0 }
    its(:available_sexes) { should eq [0, 1] }
    its('class.available_sexes') { should eq [0, 1] }

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
      include EnumAttr
      enum_attr :sex, [1, 0], default: 0
    end

    subject { TestArrayWithDefaultClass2.new }

    it { should respond_to :set_default_sex }
    it { should respond_to :sex }
    it { should respond_to :sex= }
    its(:sex) { should eq 0 }
    its(:available_sexes) { should eq [1, 0] }
    its('class.available_sexes') { should eq [1, 0] }

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
      include EnumAttr
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
    its(:available_sexes) { should eq [0, 1] }
    its('class.available_sexes') { should eq [0, 1] }

    context 'change sex...' do
      before { subject.sex = 1 }
      its(:sex) { should eq 1 }
    end

  end

  ##
  # test enum_attr in an ActiveRecord::Base class
  #
  context 'ActiveRecord::Base' do
    before do
      require 'active_record'

      ActiveRecord::Base.establish_connection('adapter' => 'sqlite3', 'database' => 'db/test.db')
      ActiveRecord::Base.logger = Logger.new(STDOUT)

      ActiveRecord::Migration.class_eval do
        drop_table :people if table_exists?(:people)

        create_table(:people) { |t| t.integer :sex }
      end

      class People < ActiveRecord::Base
        include EnumAttr

        enum_attr :sex, { male: 0, female: 1 }, default: 0
      end
    end

    context 'new' do
      subject { People.new }

      it { should respond_to :set_default_sex }
      it { should respond_to :sex }
      it { should respond_to :sex= }
      its(:sex) { should eq 0 }
      its(:available_sexes) { should eq male: 0, female: 1 }
      its('class.available_sexes') { should eq male: 0, female: 1 }

      context 'change sex to female' do
        before { subject.female! }
        its(:sex) { should eq 1 }
      end

      context 'change sex to male' do
        before { subject.male! }
        its(:sex) { should eq 0 }
      end
    end

    context 'find' do
      before { People.create(sex: 0) }

      subject { People.find 1 }

      it { should respond_to :set_default_sex }
      it { should respond_to :sex }
      it { should respond_to :sex= }
      its(:sex) { should eq 0 }
      its(:available_sexes) { should eq male: 0, female: 1 }
      its('class.available_sexes') { should eq male: 0, female: 1 }

      context 'change sex to female' do
        before { subject.female! }
        its(:sex) { should eq 1 }
      end

      context 'change sex to male' do
        before { subject.male! }
        its(:sex) { should eq 0 }
      end
    end

    context 'save' do
      before { People.create(sex: 0) }
      after { People.delete_all }

      it 'should change sex to female and save' do
        people = People.first
        people.reload.sex.should eq 0
        people.female!
        people.reload.sex.should eq 1
      end

      it 'change sex to male and save' do
        people = People.first
        people.reload.sex.should eq 0
        people.male!
        people.reload.sex.should eq 0
      end
    end

  end
end