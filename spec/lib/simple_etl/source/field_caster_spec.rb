require 'spec_helper'

module SimpleEtl
  module Source
    describe FieldCaster do
      subject { FieldCaster }

      describe '::parse_integer' do
        it 'returns nil if input is blank' do
          subject.parse_integer(nil).should be_nil
          subject.parse_integer('').should be_nil
        end

        it 'returns a number if input has only digits' do
          subject.parse_integer('43').should == 43
          subject.parse_integer('00048').should == 48
        end

        it 'accepts numeric objects' do
          subject.parse_integer(43).should == 43
        end

        it 'automatically strips spaces' do
          subject.parse_integer('  043  ').should == 43
        end

        it 'returns error with chars' do
          expect {
            subject.parse_integer 'a'
          }.to raise_error CastError
        end

        it 'returns error with commas' do
          expect {
            subject.parse_integer '1.2'
          }.to raise_error CastError
        end
      end

      describe '::parse_float' do
        it 'returns nil if input is blank' do
          subject.parse_float(nil).should be_nil
          subject.parse_float('').should be_nil
        end

        it 'returns a number if input has only digits' do
          subject.parse_float('43').should == 43.0
          subject.parse_float('00048').should == 48.0
        end

        it 'accepts numeric objects' do
          subject.parse_integer(43).should == 43.0
        end

        it 'returns a number if input has also ONE separator' do
          subject.parse_float('43.1').should == 43.1
          subject.parse_float('43,1').should == 43.1
          expect {
            subject.parse_float '43.2.1'
          }.to raise_error CastError
        end

        it 'automatically strips spaces' do
          subject.parse_integer('  043  ').should == 43
        end

        it 'returns error in every other situation' do
          expect {
            subject.parse_integer 'a'
          }.to raise_error CastError
        end
      end
    end
  end
end