require 'deck'
require 'prompt'
require 'hand'

class Player

  # defining all the options
  HIT = %w(h hit) 
  STAND = %w(st stand)
  DOUBLE_DOWN = ["dd", "double down"]
  SPLIT = %w(sp, split)

  # what can happen on the first turn
  FIRST_TURN_OPTIONS = HIT | STAND | DOUBLE_DOWN | SPLIT
  # what can happen in general
  OPTIONS = HIT | STAND

  SEP = "\n| "
  ASK_DEFAULT = "What would you like to do?"  + SEP+
      "stand: enter 'st' or 'stand'"  + SEP+
      "hit: enter 'h' or 'hit'" 
  ASK_DOUBLE_DOWN = "double down: enter 'dd' or 'double down'"  
  ASK_SPLIT = "split: enter 'sp' or 'split'"
  WRONG_INPUT = "I can't recognize your input. Try again: "

  attr_accessor :id     # player identifier
  attr_accessor :turn_over # is your turn over?
  attr_accessor :cash   # how much cash do you have?
  #attr_accessor :bet    # player's bet for the round
  #attr_accessor :busted   # are you busted?

  #attr_accessor :cards  # what cards you have
  #attr_accessor :split  # true if the player called split at some point
  #attr_accessor :cards_second # if the player called a split, the second row

  attr_accessor :hands  # array of hands. You usually have one hand
                        # => but you can have a second one if you split

  def initialize(id, cash)
    self.id = id
    self.cash = cash
    self.reset_cards
  end

  # ask the player for an initial bet on hand[0]
  def make_initial_bet
    puts("Player " + self.id.to_s + " you currently have $" + self.cash.to_s)

    # ask for a bet
    bet =  prompt("Player " + self.id.to_s + " make a bet!\n").to_i
    while bet <= 0 or bet > self.cash
      bet = prompt(
        "You can make bets of between $1 and $" + self.cash.to_s + ": ").to_i
    end

    # setup the bet
    self.hands[0].bet = bet
    self.cash -= bet
  end

  # you can win your bet on a hand
  def win_bet(hand)
    self.cash += 2*hand.bet
  end

  # have your bet returned if you are tied with dealer
  def return_bet(hand)
    self.cash += hand.bet
  end

  # lose the bet (bet goes to dealer)
  def lose_bet(hand)
    hand.bet = 0
  end 

  # the main loop of a player's turn
  def take_turn(game)
    clear_console

    self.hands.each do |hand|
      # turn counter for hand
      turn = 0

      while not hand.finished_playing
        # print the state
        clear_console
        print "Player " + self.id.to_s + "'s turn.\n"
        game.print_state_of_game

        # ask for the input
        process_options game, hand, first_turn = (turn == 0)

        turn += 1 #increment turn counter
      end
    end

  end

  # asks the player what he/she would like to do with the hand
  def process_options(game, hand, first_turn = false)
    valid_options = OPTIONS
    ask_string = ASK_DEFAULT

    # if it's the first turn, we should add double down 
    # and maybe split if applicable to valid_options
    if first_turn == true and hand.bet <= self.cash
      valid_options |= DOUBLE_DOWN
      ask_string += SEP + ASK_DOUBLE_DOWN

      # check if the two cards are the same
      if hand.can_split?
        valid_options |= SPLIT
        ask_string += SEP + ASK_SPLIT
      end
    end

    ask_string += "\nType your option: "

    # ask for input
    option = prompt ask_string

    # keep asking until we get a valid input
    while not valid_options.include? option
        option = prompt WRONG_INPUT
    end

    # parse the options
    if HIT.include? option
      self.draw game.deck, hand, silent = false
      self.check_busted hand

    elsif STAND.include? option
      puts "You decided to stand."
      hand.finished_playing = true
      wait_for_newline

    elsif DOUBLE_DOWN.include? option
      puts "You chose double down!"

      if self.cash >= hand.bet
        self.cash -= hand.bet
        hand.double_bet!

        # now, draw again
        self.draw game.deck, hand, silent = false
        game.print_state_of_game
        self.check_busted hand
        wait_for_newline
        hand.end_play!
      else
        puts "Insufficient funds."
        wait_for_newline
      end

    elsif SPLIT.include? option
      puts "You chose split!"
      self.split = true
      next_hand = Hand.new << hand.split!
      self.hands << Hand.new
    else
      # never actually reached
    end
  end

  def reset_cards
    self.hands = [Hand.new]
  end

  # draw a card from the deck into a hand
  # => by default, hand is the first hand
  def draw(deck, hand = self.hands[0], silent = true)
    card = deck.draw 
    hand.cards << card 
    if not silent
      print card.to_string + " drawn."
      wait_for_newline
    end
  end

  # check if a hand has been busted
  def check_busted (hand)
    if hand.is_busted?
      puts "Busted!"
      wait_for_newline
      self.lose_bet(hand)
      hand.end_play!
    end
  end

  # def value_of_cards
  #   value = 0  
  #   num_aces = 0
  #   for card in self.cards
  #     if card.rank == "Ace"
  #       num_aces += 1
  #     end
  #     value += card.value
  #   end

  #   counter = 0
  #   while value > 21 && counter < num_aces
  #     counter += 1
  #     value -= 10
  #   end
  #   return value
  # end

  # def cards_to_string
  #   s = ""
  #   for card in cards
  #     if not s.eql? ""
  #       s += ", "
  #     end
  #     s += card.to_string
  #   end
  #   return s
  # end

  def to_string_short
    sep = " | "
    result = "Player " + self.id.to_s + sep + "$" + self.cash.to_s + "\n"
    hands.each do |hand|
      result += "\\ bet: " + hand.bet.to_s + sep
      if hand.is_busted?
        result += "<busted>" + sep
      end
      result += "hand: "
      result += hand.to_string + "\n"
    end
    return result
  end

  # def to_string
  #   sep = "\n| "
  #   s = "Player " + self.id.to_s + sep + "$" + self.cash.to_s + sep 
  #   # s += "Bet: " + self.bet.to_s + sep
  #   if self.busted
  #     s += "Value of cards: busted" + sep
  #   else
  #     s += "Value of cards: " + self.value_of_cards.to_s + sep
  #   end
  #   s += "Cards: " + self.cards_to_string + "\n" 
  # end

  def is_dealer
    self.id == DEALER_ID
  end
end