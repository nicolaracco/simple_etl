require 'spec_helper'

module SimpleEtl
  module Source
    describe Row do
      it 'should use reflection over its attributes' do
        r = Row.new
        r.attributes[:name] = 'w'
        r.name.should == 'w'
      end

      it 'has a valid accessor' do
        r = Row.new
        r.should be_valid
        r.errors << 'w'
        r.should_not be_valid
      end
    end
  end
end