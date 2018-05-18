require 'spec_helper'
require File.dirname(__FILE__) + '/../../lib/recipie_parser'

class Recipie
end

RSpec.describe RecipieParser do
  describe '.parse' do
    expect(RecipieParser.parse(File.open(File.dirname(__FILE__) + '/../support/example_recipie_webpages/bbc_good_food_chickpea_curry.html'))).to be_a(Recipie)
  end
end
