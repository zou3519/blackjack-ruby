require 'deck'
require 'prompt'
require 'hand'

class Player

  ################### player move options ######################
  HIT = %w(h hit) 
  STAND = %w(st stand)
  DOUBLE_DOWN = ["dd", "double down"]
  SPLIT = %w(sp split)

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

  ################ accessors + initializer ###################

  attr_accessor :id     # player identifier
  attr_accessor :cash   # how much cash do you have?
  attr_accessor :hands  # array of hands. You usually have one hand
                        # => but you can have a second one if you split
  attr_accessor :current_hand_index # for printing purposes

  # initialize a player with a number and an amount of cash
  def initialize(id, cash)
    self.id = id
    self.cash = cash
    self.reset_cards
  end

  ##################### questions ######################

  # construct the player's name. 
  def name?
    "Player " + self.id.to_s
  end

  # is the player out of money?
  def out?
    self.cash <= 0
  end

  # is the player the dealer?
  def is_dealer?
    self.id == DEALER_ID
  end

  ##################### the player's turn ######################
  # the main loop of a player's turn
  def take_turn(game)
    clear_console

    self.hands.each do |hand|
      # turn counter for hand
      turn = 0
      self.current_hand_index += 1
      while not hand.finished_playing
        # print the state
        clear_console
        print "Player " + self.id.to_s + "'s turn.\n"
        game.print_state_of_game(
          bet = true, dealer_only_first_card = true, show_val = false)

        if hand.is_blackjack?
          puts "Blackjack!"
          hand.end_play!
          wait_for_newline
        else 
          # ask for the input
          process_options game, hand, first_turn = (turn == 0)
        end

        turn += 1 #increment turn counter
      end
    end

    self.current_hand_index += 1
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
    case option
    when *HIT
      self.hit(game, hand)
    when *STAND
      self.stand(game, hand)
    when *SPLIT
      double_down(game, hand)
    else # double down
      self.double_down(game, hand) 
    end

    # if HIT.include? option
    #   self.hit(game, hand)

    # elsif STAND.include? option
    #   self.stand(game, hand)

    # elsif DOUBLE_DOWN.include? option
    #   self.double_down(game, hand)

    # elsif SPLIT.include? option
    #   self.split(game, hand)
    # else
    #   # never actually reached
    # end
  end

  ################# Player choices on a hand ################

  def hit(game, hand)
    self.draw game.deck, hand, silent = false
    self.check_busted hand
  end

  def stand(game, hand)
    puts "You decided to stand."
    hand.end_play!
    wait_for_newline
  end

  def double_down(game, hand)
    puts "You chose double down!"

    if self.cash >= hand.bet
      self.cash -= hand.bet
      hand.double_bet!

      # now, draw again
      self.draw game.deck, hand, silent = false
      self.check_busted hand
      wait_for_newline
      hand.end_play!
    else
      puts "Insufficient funds."
      wait_for_newline
    end
  end

  def split(game, hand)
    puts "You chose split!"
    if self.cash >= hand.bet
      self.hands << hand.split!
      self.cash -= hand.bet
    else
      puts "Insufficient funds"
      wait_for_newline
    end
  end

  ##################### bet handling ######################

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
    # if you have a blackjack, win 3:2 and get original bet back
    if hand.is_blackjack?
      self.cash += hand.bet + 1.5*hand.bet
    else
      self.cash += 2*hand.bet
    end
  end

  # have your bet returned if you are tied with dealer
  def return_bet(hand)
    self.cash += hand.bet
  end

  # lose the bet (bet goes to dealer)
  def lose_bet(hand)
    #hand.bet = 0
  end 

  ################# Misc. Utility functions ################
  def reset_cards
    self.hands = [Hand.new]
    self.current_hand_index = -1
  end

  # draw a card from the deck into a hand
  # => by default, hand is the first hand
  def draw(deck, hand = self.hands[0], silent = true)
    card = deck.draw 
    hand.cards << card 
    if not silent
      print card.to_string + " drawn. "
      wait_for_newline
    end
  end

  # check if a hand has been busted
  def check_busted (hand)
    if hand.is_busted?
      puts "Busted!"      
      self.lose_bet(hand)
      hand.end_play!
      wait_for_newline
    end
  end

  # string representation of player
  def to_string(show_bet=true, only_first_card = false, value = false)
    sep = " | "

    # print name and cash
    result = "| " + self.name? + sep 
    result += "$" + self.cash.to_s + "\n"

    # print each hand
    hands.each_index do |h|
      hand = hands[h]
      result += " \\ " + hand.to_string(show_bet, only_first_card, value)
      if h == self.current_hand_index
        result += " <- current"
      end
      result += "\n"
    end
    return result
  end

end