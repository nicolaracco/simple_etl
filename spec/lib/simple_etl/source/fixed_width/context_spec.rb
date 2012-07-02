require 'spec_helper'

module SimpleEtl
  module Source
    module FixedWidth
      describe Context do
        subject { FixedWidth::Parser.new.context }

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

          it 'should accept the special :eol length' do
            expect {
              subject.field :name, 5, :eol
            }.to_not raise_error
          end
        end
      end
    end
  end
end