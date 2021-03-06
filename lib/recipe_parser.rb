require 'nokogiri'
require 'ostruct'

class Recipe < OpenStruct
end

class IngredientItem < OpenStruct
  def to_s
    if quantity_unit
      "#{UNITS[quantity_unit][:to_s] % quantity} #{name}"
    end
  end
end

UNITS = {
  :table_spoon => {
    regexp: /(\d+)\s*(tbsp|table\s?spoon)s?\s/i,
    to_s: "%s tbsp"
  },
  :tea_spoon => {
    regexp: /(\d+)\s*(tsp|tea\s?spoon)s?\s/i,
    to_s: "%s tsp"
  },
  :grams => {
    regexp: /(\d+)\s*(g|gram)s?\s/,
    to_s: "%sg"
  },
  :millilitres => {
    regexp: /(\d+)\s*(ml|mils|milli\slitre)s?\s/,
    to_s: "%sml"
  },
  :none => {
    regexp: /(\d*)/,
    to_s: "%s x"
  }
}

class RecipeParser
  def self.parse(file)
    file.respond_to?(:read) ? new(file.read).parse : new(file).parse
  end

  def initialize(html)
    @document = Nokogiri::HTML(html)
  end
  private_class_method :new

  def parse
    Recipe.new(ingredient_items: []).tap do |recipe|
      ingredient_elements.each do |ingredient_element|
        recipe.ingredient_items.push(IngredientItemParser.parse(ingredient_element))
      end

      recipe.ingredient_items.compact!
    end
  end

  private

  def ingredient_elements
    foo = @document.css('li[class*="ingredient"]')
    if foo.length > 0
      foo
    else
      @document.css('li [class*="ingredient"]')
    end
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
    if quantity_match && name_match
      IngredientItem.new(name: name_match, quantity: quantity, quantity_unit: quantity_unit)
    end
  end

  private

  def quantity
    quantity_match && quantity_match[:quantity]
  end

  def quantity_unit
    quantity_match && quantity_match[:unit]
  end

  def lines
    @lines ||= @html_element.children.map(&:text).join("\n").lines
  end

  def name_match
    if quantity_match
      @name_match ||= begin
        quantity_line_with_quantity_removed = lines[quantity_match[:index]].gsub(quantity_match[:match], '').strip
        if quantity_line_with_quantity_removed.match(/[a-z]+/i)
          quantity_line_with_quantity_removed.strip.capitalize
        else
          name_line = lines[quantity_match[:index] + 1, lines.length - 1].detect do |line|
            line.match(/[a-z]+/i)
          end

          name_line&.strip&.capitalize
        end
      end
    end
  end

  def quantity_match
    @quantity_match ||= lines.each_with_index do |line, index|
      UNITS.each do |unit, unit_info|
        if match = line.match(unit_info[:regexp])
          quantity = (match[1].empty? ? 1 : match[1]).to_i
          return { match: match[0], quantity: quantity, unit: unit, index: index }
        end
      end
    end
    nil
  end
end
