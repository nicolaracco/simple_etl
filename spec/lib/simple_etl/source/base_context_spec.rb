require 'spec_helper'

module SimpleEtl
  module Source
    describe BaseContext do
      subject { BaseContext.new }

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
  end
end