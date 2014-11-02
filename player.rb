require 'deck'
require 'prompt'

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
  attr_accessor :bet    # player's bet for the round
  attr_accessor :busted   # are you busted?

  attr_accessor :cards  # what cards you have
  attr_accessor :split  # true if the player called split at some point
  attr_accessor :cards_second # if the player called a split, the second row

  def initialize(id, cash)
    self.id = id
    self.cash = cash
    self.reset_cards
  end

  def make_bet
    puts("Player " + self.id.to_s + " you currently have $" + self.cash.to_s)

    # ask for a bet
    self.bet =  prompt("Player " + self.id.to_s + " make a bet!\n").to_i
    while self.bet <= 0 or self.bet > self.cash
      self.bet = prompt(
        "You can make bets of between $1 and $" + self.cash.to_s + ": ").to_i
    end

    self.cash -= bet
  end

  def win_bet
    self.cash += 2*self.bet
  end

  def return_bet
    self.cash += self.bet
  end

  def lose_bet ; end # tis very unfortunate

  # the main loop of a player's turn
  def take_turn(game)
    clear_console
    self.turn_over = false

    # turn counter
    turn = 0

    while not self.turn_over
      # print the state
      clear_console
      print "Player " + self.id.to_s + "'s turn.\n"
      game.print_state_of_game

      # ask for the input
      process_options game, first_turn = (turn == 0)

      turn += 1 #increment turn counter
    end
  end

  def process_options(game, first_turn = false, cards_list = self.cards)
    valid_options = OPTIONS
    ask_string = ASK_DEFAULT

    # if it's the first turn, we should add double down 
    # and maybe split if applicable to valid_options
    if first_turn == true and self.bet <= self.cash
      valid_options |= DOUBLE_DOWN
      ask_string += SEP + ASK_DOUBLE_DOWN

      # check if the two cards are the same
      if self.cards[0].rank.eql? self.cards[1].rank
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

    # parse the option
    if HIT.include? option
      self.draw game.deck, silent = false
      self.check_busted

    elsif STAND.include? option
      puts "You decided to stand."
      self.turn_over = true
      wait_for_newline

    elsif DOUBLE_DOWN.include? option
      puts "You chose double down!"

      if self.cash >= self.bet
        self.cash -= self.bet
        self.bet = 2*self.bet

        # now, draw again
        self.draw game.deck, silent = false
        self.check_busted
        puts self.to_string
        wait_for_newline
        self.turn_over = true
      else
        puts "Insufficient funds."
        wait_for_newline
      end

    elsif SPLIT.include? option
      puts "You chose split!"
      self.split = true
      self.cards_second << cards.pop
      @first_split_done = false
    else
      # never actually reached
    end
  end

  def reset_cards
    @num_aces = 0
    self.cards = []
    self.busted = false
    split = false
  end

  # draw a card from the deck
  def draw(deck, silent = true, cards_list = self.cards)
    card = deck.draw 
    cards_list << card 
    if not silent
      print card.to_string + " drawn. (Press enter to continue)"
      gets
      print "\n"
    end
  end

  def check_busted (hand = self.cards)
    if self.value_of_cards > 21
      puts "Busted!"
      wait_for_newline
      self.lose_bet
      self.busted = true
      self.turn_over = true
    end
  end

  def value_of_cards
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


  def cards_to_string
    s = ""
    for card in cards
      if not s.eql? ""
        s += ", "
      end
      s += card.to_string
    end
    return s
  end

  def to_string_short
    sep = " | "
    result = "Player " + self.id.to_s + sep + "$" + self.cash.to_s + sep 
    if self.busted
      result += "busted"
    else 
      result += "bet: $" + self.bet.to_s
    end
    result +=  sep + cards_to_string
    return result
  end

  def to_string
    sep = "\n| "
    s = "Player " + self.id.to_s + sep + "$" + self.cash.to_s + sep 
    # s += "Bet: " + self.bet.to_s + sep
    if self.busted
      s += "Value of cards: busted" + sep
    else
      s += "Value of cards: " + self.value_of_cards.to_s + sep
    end
    s += "Cards: " + self.cards_to_string + "\n" 
  end

  def is_dealer
    self.id == DEALER_ID
  end
end