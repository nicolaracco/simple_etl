require 'spec_helper'

module SimpleEtl
  module Source
    describe FixedWidth do
      describe '::new' do
        it 'should execute the block in the context' do
          FixedWidth.new { self.class.should == FixedWidth::Context }
        end
      end

      describe '#fetch_field_from_row' do
        it 'should use field attributes to fetch a field' do
          subject.fetch_field_from_row('ITM', { :start => 0, :length => 2 }).should == 'IT'
        end
      end

      describe FixedWidth::Context do
        subject { FixedWidth.new.context }

        describe '#field' do
          it 'should append the field definition in the fields list' do
            subject.field :name, 10, 20
            subject.fields.should =~ [{:name => :name, :start => 10, :length => 20, :required => false, :type => :object}]
          end

          it 'should raise error if start arg is missing' do
            expect{
              subject.field :name, nil, 10
            }.to raise_error FieldArgumentError
          end

          it 'should raise error if length arg is missing' do
            expect{
              subject.field :name, 10, nil
            }.to raise_error FieldArgumentError
          end

          it 'should raise error if start is not an integer' do
            expect {
              subject.field :name, 'pippo', 20
            }.to raise_error FieldArgumentError
          end

          it 'should raise error if length is not an integer' do
            expect {
              subject.field :name, 5, 'pippo'
            }.to raise_error FieldArgumentError
          end

          it 'should accept the special :eof length' do
            expect {
              subject.field :name, 5, :eof
            }.to_not raise_error
          end
        end
      end
    end
  end
end