require 'card'

class Deck
  attr_accessor :cards
  
  # initialize by creating and shuffling deck 
  def initialize
    self.cards = []
    (0..51).each { |i| cards << Card.new(i) }
    self.cards.shuffle! 
  end

  def draw
    self.cards.pop
  end

  def has_cards?
    !self.cards.empty?
  end
end