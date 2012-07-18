require 'spec_helper'

module SimpleEtl
  module Source
    describe Base do
      subject { Base.new BaseContext.new }

      describe '#parse_field' do
        before do
          subject.stub :fetch_field_from_row do |row, field|
            row
          end
        end

        it 'should socks at brush' do
          expect {
            subject.parse_field Object.new, { :name => 'IT', :type => :object, :required => true }, Row.new
          }.to_not raise_error
        end

        it 'raises an error if field is required but blank' do
          [nil, ''].each do |val|
            FieldCaster.stub! :parse_object => val
            expect {
              subject.parse_field '', { :name => 'IT', :type => :object, :required => true }, Row.new
            }.to raise_error
          end
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
        let(:r) { Row.new :attributes => {:foo => 'w'} }

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
            subject.context.generate(:foo) { sample }
            subject.should_receive :generate_field
            subject.parse_row 'ITM'
          end

          it 'launches the generator even if the overall result is not valid' do
            subject.context.field :sample
            # it will raise error if s not have sample
            subject.context.generate(:foo) { sample }
            subject.should_receive :generate_field
            subject.parse_row 'ITM', :result => double(ParseResult, :valid? => false, :rows => [])
          end
        end
      end

      describe '#parse' do
        before do
          subject.stub :read_rows => [[], []]
        end

        it 'should skip first rows if specified in context' do
          subject.parse(nil).rows.count.should == 2
          subject.context.skip_rows 1
          subject.parse(nil).rows.count.should == 1
        end
      end
    end
  end
end