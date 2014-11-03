require 'deck'
require 'player'
require 'dealer'
require 'prompt'

class Game

  ######################### accessors + init #######################

  attr_accessor :players      # list of players.  the dealer is a player
  attr_accessor :dealer       # the dealer
  attr_accessor :deck         # a Deck instance
  attr_accessor :is_game_over # is the game over yet?

  START_CASH = 1000

  def initialize
    self.is_game_over = false

    puts "Welcome to Blackjack!"
    wait_for_newline

    # get the number of players
    num_players = get_num_players

    # get the initial cash
    start_cash = START_CASH

    # create the players
    self.players = [];
    (1..num_players).each { |i| self.players << Player.new(i, start_cash) }

    # create the dealer, add him/her to players
    self.dealer = Dealer.new
    self.players << self.dealer

    # game won't end until all the players lose their money
    while not is_game_over
      self.play_round
    end

    puts "Game over! Thanks for playing!"
  end

  # prompt for the number of human players
  def get_num_players
    num_players = 
      prompt("How many people are playing?\nEnter a number: ").to_i
    while num_players <= 0
      num_players = prompt("Enter a number greater than 0: ").to_i
    end
    return num_players
  end

  # prompt for how much each person should start with. Not actually called.
  def get_start_cash
    start_cash = 
      prompt(
        "How much money should everyone start with?\nEnter a number: $").to_i
    while start_cash <= 0
      start_cash = prompt("Enter a number greater than 0: ").to_i
    end
    return start_cash
  end

  ######################### Game functions #######################

  # play a round of the game. this is looped constantly
  def play_round
    self.deck = Deck.new

    # reset players' cards, have them make bets, and then deal
    reset_cards
    make_bets
    deal_cards

    # if the dealer has blackjack, play immediately ends
    if (dealer.hands[0].is_blackjack?)
      clear_console
      puts "Dealer has blackjack!"
      print_state_of_game
      wait_for_newline
    else
      # let every player take their turns
      players.each do |player|
        clear_console
        player.take_turn(self)
      end
    end

    # now, calculate how much people win/lose
    resolve_bets
    wait_for_newline

    # finish with a summary of the round and remove players with 0 cash
    print_round_summary
    remove_players
  end

  # return all cards to dealer.  deck is automatically shuffled
  def reset_cards
    self.deck = Deck.new
    players.each { |player| player.reset_cards }
  end

  # have everyone make their bets
  def make_bets
    players.each { |player| player.make_initial_bet }
  end

  # deal one card to everyone twice
  def deal_cards
    (0..1).each do |i|
      players.each { |player| player.draw(self.deck) }
    end
  end

  # remove the players who have no cash left
  def remove_players
    to_remove = []
    players.each do |player|
      if player.out?
        to_remove << player
      end
    end
    to_remove.each { |player| players.delete(player) }
    if players.length == 1
      self.is_game_over = true
    end
  end

  # call this after play ends to resolve bets
  def resolve_bets
    dealer_hand = dealer.hands[0]

    # Case 1: dealer goes bust
    # => if a player's hand was bust, do nothing
    # => otherwise, the hand wins
    if dealer_hand.is_busted?
      players.each do |player|
        player.hands.each do |hand|
          if not hand.is_busted?
            player.win_bet hand
          end
        end
      end

    # Case 2: dealer is not bust
    # => if a hand went bust, do nothing
    # => otherwise, if the hand's value is greater, the hand wins the bet
    # => otherwise, if the hand's value is smaller, the hand wins the bet
    # => otherwise, if the hand and dealer are tied, the money is pushed back
    else
      players.each do |player|
        player.hands.each do |hand|
          if not player.is_dealer? and not hand.is_busted?

            if hand.value? > dealer_hand.value?
              player.win_bet hand

            elsif hand.value? < dealer_hand.value?
              player.lose_bet hand

            else # dealer and player are tied
              player.return_bet hand 
            end

          end
        end
      end
    end
  end

  ######################### Printing functions #######################

  def print_round_summary
    # print a summary
    clear_console
    puts "-------------------- Round Summary ----------------------"
    print_state_of_game(bet = false, only_first_card = false, show_val = true)

    # say we're going to remove players.  
    # actual removal occurs in remove_players
    players.each do |player|
      if player.out?
        puts "Removing " + player.name? + " due to having $0 left."
      end
    end

    wait_for_newline
  end

  # things that the players see
  def print_state_of_game(bet = true, dealer_only_first_card = false, 
    show_val = false)

    puts "------------------------ Table --------------------------"
    players.each_index do |p|
      player = players[p]

      # formatting
      if p > 0
        puts "|"
      end

      # hide the dealer's card if necessary
      if player.is_dealer?
        only_first_card = dealer_only_first_card
      else
        only_first_card = false
      end

      # hurray!
      puts player.to_string(bet, only_first_card, show_val)
    end
    puts "---------------------------------------------------------"
  end
end