require 'spec_helper'

module SimpleEtl
  module Source
    describe ParseResult do
      describe '#valid?' do
        it 'is true if there are no errors' do
          subject.should be_valid
        end

        it 'is false if there are errors' do
          subject.rows << Row.new
          subject.rows.first.errors << 'w'
          subject.should_not be_valid
        end
      end

      describe '#errors' do
        it 'is a collection of all row errors' do
          [Row.new, Row.new].each do |row|
            2.times { row.errors << 'w' }
            subject.rows << row
          end
          subject.errors.count.should == 4
        end
      end
    end
  end
end