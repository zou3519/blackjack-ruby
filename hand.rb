require 'deck'

# a Hand represents a player's hand.
# => A player can bet on a hand; when he declares "split",
# => he essentially has two hands.
class Hand
  
  attr_accessor :cards, :bet, :finished_playing, :splittable

  # by default, we can split a hand
  def initialize (splittable = true)
    self.cards = []
    self.bet = 0
    self.finished_playing = false
    self.splittable = splittable
  end

  def end_play!
    self.finished_playing = true
  end

  def double_bet!
    self.bet = self.bet*2
  end

  # assuming that we're splittable, return one of the two cards
  def split!
    return cards.pop
  end

  # can we split the hand, assuming sufficient funds?
  def can_split?
    self.cards.length == 2 and 
      self.cards[0].rank == self.cards[1].rank and
      splittable
  end

  def is_busted?
    self.value? > 21
  end

  # compute the value of the hand
  #   value will choose values for the aces (1 or 11)
  #   by first trying to maximize the total sum <= 21,
  #   and, when that is not possible, return the minimum total sum > 21
  def value? 
    value = 0  
    num_aces = 0

    # add up maximum values
    self.cards.each do |card|
      if card.rank == "Ace"
        num_aces += 1
      end
      value += card.value
    end

    # subtract 10 for as many aces we have
    # to get the result just under 21
    counter = 0
    while value > 21 && counter < num_aces
      counter += 1
      value -= 10
    end
    return value
  end

  def to_string
    result = ""
    cards.each do |card| 
      if result != "" 
        result += ", "
      end
      result += card.to_string 
    end
    return result
  end
end