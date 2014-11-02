require 'deck'

# a Hand represents a player's hand.
# when a player splits his two cards, he essentially has two hands
class Hand
  
  attr_accessor :cards, :bet, :busted, :is_hand_complete

  # compute the value of the hand
  #   value will choose values for the aces (1 or 11)
  #   by first trying to maximize the total sum <= 21,
  #   and, when that is not possible, return the minimum total sum > 21
  def value? 
    value = 0  
    num_aces = 0
    for card in self.cards
      if card.rank == "Ace"
        num_aces += 1
      end
      value += card.value
    end

    counter = 0
    while value > 21 && counter < num_aces
      counter += 1
      value -= 10
    end
    return value
  end

end