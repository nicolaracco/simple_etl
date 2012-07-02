require 'spec_helper'

module SimpleEtl
  module Source
    module FixedWidth
      describe Parser do
        describe '::new' do
          it 'should execute the block in the context' do
            FixedWidth::Parser.new { self.class.should == FixedWidth::Context }
          end
        end

        describe '#fetch_field_from_row' do
          it 'should use field attributes to fetch a field' do
            subject.fetch_field_from_row('ITM', { :start => 0, :length => 2 }).should == 'IT'
          end

          it 'should fetch till the end of line if length is :eol' do
            subject.fetch_field_from_row('ITM', { :start => 1, :length => :eol }).should == 'TM'
          end
        end
      end
    end
  end
end