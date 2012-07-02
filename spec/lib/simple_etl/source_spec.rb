require 'spec_helper'

module SimpleEtl
  describe Source do
    describe '::define' do
      it 'should return a new template' do
        tpl = SimpleEtl::Source.define :fixed_width do
          integer :name, 10, 12
        end
        tpl.context.fields.size.should == 1
      end

      it 'should raise error if format not exist' do
        expect {
          SimpleEtl::Source.define :piipo do; end
        }.to raise_error
      end
    end

    describe '::load' do
      it 'should raise an error if file not exist' do
        expect {
          SimpleEtl::Source.load 'pappopappo'
        }.to raise_error
      end

      it 'should load correctly' do
        file = File.join FIXTURES_PATH, "sample.stl"
        SimpleEtl::Source.load(file).should be_kind_of SimpleEtl::Source::Base
      end
    end
  end
end