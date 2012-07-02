# Load the Sinatra app
require File.dirname(__FILE__) + '/../lib/simple_etl'
require 'rspec'

Dir[File.expand_path(File.join(File.dirname(__FILE__),'support','**','*.rb'))].each {|f| require f}

FIXTURES_PATH = File.expand_path File.join File.dirname(__FILE__), "fixtures"

RSpec.configure do |conf|
  conf.before :suite do
  end
end
