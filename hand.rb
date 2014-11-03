require 'deck'

# a Hand represents a player's hand.
# => A player can bet on a hand; when he declares "split",
# => he essentially has two hands.
class Hand
  
  attr_accessor :cards, :bet, :finished_playing, :splittable
  attr_accessor :can_have_blackjack

  # by default, we can split a hand
  def initialize (splittable = true)
    self.cards = []
    self.bet = 0
    self.finished_playing = false
    self.splittable = splittable
    self.can_have_blackjack = true
  end

  # signify that this hand has finished play
  def end_play!
    self.finished_playing = true
  end

  # double the bet.  Called in player's double down option
  def double_bet!
    self.bet = self.bet*2
  end

  # assuming that we're splittable, return one of the two cards
  def split!
    self.can_have_blackjack = false
    new_hand = Hand.new
    new_hand.cards << self.cards.pop
    new_hand.bet = self.bet
    new_hand.can_have_blackjack = false
    return new_hand
  end

  # can we split the hand, assuming sufficient funds?
  def can_split?
    self.cards.length == 2 and 
      self.cards[0].value == self.cards[1].value and
      splittable
  end

  # has the hand busted?
  def is_busted?
    self.value? > 21
  end

  # is this hand a blackjack?
  def is_blackjack?
    self.can_have_blackjack and self.cards.length == 2 and self.value? == 21
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

  # turns the hand to string.
  # => show_bet = true will show the bet value of the hand
  # => only_first_card = true will show only the first card
  # => show_value will print the value of the hand (if not busted)
  def to_string (show_bet = false, only_first_card = false, 
    show_value = false)

    result = ""

    # display the bet
    if show_bet
      result += "bet: $" + self.bet.to_s + " | "
    end

    # display a busted keyword
    if self.is_busted?
      result += "busted! | "
    end

    # display the list of cards
    cards.each_index do |c| 
      card = cards[c]
      if c > 0 
        result += ", "
      end
      if only_first_card and c >= 1
        result += "<hidden card>"
      else
        result += card.to_string 
      end
    end

    # display value only if not busted and show_value is on
    if show_value and not self.is_busted?
      result += " | " + "value: " + self.value?.to_s
    end
    return result
  end
end