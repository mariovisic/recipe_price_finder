require 'nokogiri'
require 'ostruct'

class Recipe < OpenStruct
end

class IngredientItem < OpenStruct
  TABLE_SPOON = 'tbsp'

  def to_s
    "#{quantity} #{quantity_unit} of #{name}"
  end
end


class RecipieParser
  def self.parse(file)
    file.respond_to?(:read) ? new(file.read).parse : new(file).parse
  end

  def initialize(html)
    @document = Nokogiri::HTML(html)
  end
  private_class_method :new

  def parse
    rec = Recipe.new(ingredient_items: []).tap do |recipie|
      ingredient_elements.each do |ingredient_element|
        recipie.ingredient_items.push(IngredientItemParser.parse(ingredient_element))
      end
    end
  end

  private

  def ingredient_elements
    @document.xpath('//li[contains(@class, "ingredient")]')
  end
end

class IngredientItemParser
  def self.parse(html_element)
    new(html_element).parse
  end

  def initialize(html_element)
    @html_element = html_element
  end

  def parse
    IngredientItem.new(element: @html_element, quantity: quantity, quantity_unit: quantity_unit, name: name)
  end

  private

  def name
    if quantity_string
      line_with_quantity.sub(quantity_string, '').strip.capitalize
    end
  end

  def quantity
    if quantity_string
      quantity_string.split(' ').first.to_i
    end
  end

  def quantity_unit
    if quantity_string
      quantity_string.split(' ').last
    end
  end


  def quantity_string
    @quantity ||= begin
      if (@html_element.text.match /\d tbsp/i)
        @html_element.text.match(/\d tbsp/i)[0]
      end
    end
  end

  def line_with_quantity
    @html_element.text.split("\n").detect do |line|
      line.match?(/\d tbsp/i)
    end
  end
end
