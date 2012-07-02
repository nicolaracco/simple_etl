require 'spec_helper'

module SimpleEtl
  module Source
    describe Row do
      it 'should use reflection over its attributes' do
        r = Row.new :name => 'w'
        r.name.should == 'w'
      end
    end
  end
end