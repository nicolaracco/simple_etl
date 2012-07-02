require 'spec_helper'

module SimpleEtl
  module Source
    describe ParseResult do
      describe '#valid?' do
        it 'is true if there are no errors' do
          subject.should be_valid
        end

        it 'is false if there are errors' do
          subject.append_error 0, 'm', Exception.new
          subject.should_not be_valid
        end
      end
    end
  end
end