require 'spec_helper'
require File.dirname(__FILE__) + '/../../lib/recipie_parser'

RSpec.describe RecipieParser do
  let(:recipe_html_file) { File.read(File.dirname(__FILE__) + '/../support/example_recipie_webpages/bbc_good_food_chickpea_curry.html') }

  describe '.parse' do
    it 'returns a Recipie object' do
      expect(RecipieParser.parse(recipe_html_file)).to be_a(Recipe)
    end

    it 'correctly sets the number of ingredients on the recipie' do
      expect(RecipieParser.parse(recipe_html_file).ingredient_items.count).to eq(12)
    end
  end
end


RSpec.describe IngredientItemParser do

  let(:html) { %{<li class="ingredients-list__item" itemprop="ingredients" content="1 tbsp olive oil">1 tbsp <a href="/glossary/olive-oil" class="ingredients-list__glossary-link" data-tooltip-content="#ingredients-glossary &gt; article" data-tooltip-width="350" data-tooltip-hide-delay="200" data-tooltip-flyout="true">olive oil</a><span class="ingredients-list__glossary-element" id="ingredients-glossary"><article id="node-259466" role="main" class="node node-glossary-item node-teaser node-teaser clearfix main row grid-padding"><div class="node-image"> <a href="/glossary/olive-oil"><img src="//www.bbcgoodfood.com/sites/default/files/styles/bbcgf_thumbnail_search/public/glossary/olive-oil.jpg?itok=n4dxcprV" width="100" height="100" alt="olive oil" title="olive oil"></a>
</div>
<h2 class="node-title node-glossary-title"><a href="/glossary/olive-oil">Olive oil</a></h2> <span class="fonetic text-style-alt">ol-iv oyl</span><p>Probably the most widely-used oil in cooking, olive oil is pressed from fresh olives. It's…</p> </article></span>
</li>} }

  describe '.parse' do
    it 'returns an IngredientItem object' do
      expect(IngredientItemParser.parse(Nokogiri::XML::Document.parse(html))).to be_a(IngredientItem)
    end

    it 'correctly extracts the quantity of the ingredients' do
      expect(IngredientItemParser.parse(Nokogiri::XML::Document.parse(html)).quantity).to eq(1)
      expect(IngredientItemParser.parse(Nokogiri::XML::Document.parse(html)).quantity_unit).to eq(:table_spoon)
    end

    it 'correctly extracts the name of the ingredients' do
      expect(IngredientItemParser.parse(Nokogiri::XML::Document.parse(html)).name).to eq('Olive oil')
    end
  end
end
