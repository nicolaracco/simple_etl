require 'spec_helper'

module SimpleEtl
  module Source
    describe Base do
      subject { Base.new Base::Context.new }

      describe Base::Context do
        subject { Base::Context.new }

        describe '#field' do
          it 'should append the field definition in the fields list' do
            subject.field :name
            subject.fields.should =~ [{:name => :name, :required => false, :type => :object}]
          end

          it 'should raise error if type is present and unknown' do
            expect{
              subject.field :name, :type => 'pippo'
            }.to raise_error FieldArgumentError
          end
        end

        describe 'field helpers' do
          it 'should have an helper for each caster' do
            subject.string :name
            subject.fields.should =~ [{:name => :name, :type => :string, :required => false}]
          end

          it 'should have a required helper for each caster' do
            subject.required_string :name
            subject.fields.should =~ [{:name => :name, :type => :string, :required => true}]
          end
        end

        describe 'transform' do
          it 'should append to transformations' do
            subject.field :name
            expect {
              subject.transform :name do; end
            }.to change(subject.transformations, :size).by 1
          end

          it 'should raise error if field is not specified' do
            expect {
              subject.transform :name do; end
            }.to raise_error FieldNotFoundError
          end
        end

        describe 'generate' do
          it 'should append to generators' do
            expect {
              subject.generate :name do; end
            }.to change(subject.generators, :size).by 1
          end
        end
      end

      describe '#parse_field' do
        before do
          subject.stub :fetch_field_from_row do |row, field|
            row
          end
        end

        it 'should socks at brush' do
          expect {
            subject.parse_field 'ITM', { :name => 'IT', :type => :object }, Row.new
          }.to_not raise_error
        end

        context 'when there is a transformation' do
          it 'should apply it' do
            subject.context.field :foo
            subject.context.transform :foo do |s|
              "pippo"
            end
            subject.parse_field('ITM', { :name => :foo, :type => :object }, Row.new).should == "pippo"
          end

          it 'should set the context to the current row object' do
            context = subject.context
            context.field :foo
            context.transform(:foo) { |s| self.class.should == Row }
            subject.parse_field 'ITM', { :name => :foo, :type => :object }, Row.new
          end

          it 'passes the field value as argument' do
            subject.stub(:fetch_field_from_row) { |row, field| 'pippo' }
            subject.context.field :foo
            subject.context.transform(:foo) { |s| s.should == 'pippo' }
            subject.parse_field 'ITM', { :name => :foo, :type => :object }, Row.new
          end
        end
      end

      describe '#generate_field' do
        let(:r) { Row.new :foo => 'w' }

        it 'should set the context to the current row' do
          block = lambda { self.class.should == Row }
          subject.generate_field({ :name => :mio, :block => block }, r)
        end

        it 'should socks at brush' do
          subject.generate_field({ :name => :mio, :block => lambda { foo } }, r).should == r.foo
        end

        it 'can raise ParseError without specifing path' do
          block = lambda { raise ParseError }
          expect {
            subject.generate_field({ :name => :mio, :block => block }, r)
          }.to raise_error ParseError
        end
      end

      describe '#parse_row' do
        before do
          subject.stub :fetch_field_from_row do |row, field|
            row
          end
        end

        it 'should return a ParseResult object' do
          subject.parse_row('').should be_kind_of ParseResult
        end

        it 'should insert attributes in row' do
          subject.context.field :sample
          subject.parse_row('ITM').rows.first.sample.should == 'ITM'
        end

        context 'when row is not valid' do
          it 'should not execute generators' do
            subject.stub :fetch_field_from_row do |row, field|
              raise ParseError
            end
            subject.context.field :sample
            subject.context.generate :foo do |s|
              "pippo"
            end
            subject.parse_row('ITM').public_methods.should_not include :foo
          end
        end

        context 'when row is valid' do
          it 'launches the generator giving the row instance' do
            subject.context.field :sample
            # it will raise error if s not have sample
            subject.context.generate :foo do
              sample
            end
            expect { subject.parse_row('ITM') }.to_not raise_error
          end
        end
      end
    end
  end
end