require 'deck'
require 'player'
require 'dealer'
require 'prompt'

class Game
  # list of players, total number of players, and number of current player
  attr_accessor :players, :num_players, :cur_player, :dealer, :gameOver, :deck

  def initialize
    puts "Welcome to Blackjack!"
    wait_for_newline

    # get the number of players
    num_players = prompt("How many people are playing?\n").to_i
    while num_players <= 0
      num_players = prompt("Enter a number greater than 0: ").to_i
    end

    # get the initial cash
    start_cash = 
      prompt("How much money should everyone start with?\n").to_i

    while num_players <= 0
      start_cash = prompt("Enter a number greater than 0: ").to_i
    end

    # num_players = 1
    # start_cash = 1000

    # create the players
    self.players = [];
    for i in 1..num_players
      self.players << Player.new(i, start_cash)
    end

    # create the dealer, add to players
    self.dealer = Dealer.new
    self.players << self.dealer

    while true
      self.play_round
    end
  end

  def play_round
    self.deck = Deck.new

    # reset players' cards, have them make bets, and then deal
    for i in 0..1
      players.each do |player|
        if i == 0:
          clear_console
          # clear the players' cards and have them make bets
          player.reset_cards
          if not player.is_dealer?
            player.make_initial_bet
          end
        end
        player.draw(deck)
      end
    end

    # if the dealer has blackjack...
    if (dealer.hands[0].is_blackjack?)
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

    # if dealer has blackjack..
    if dealer.hands[0].is_blackjack?
      players.each do |player|
        player.hands.each do |hand|
          if hand.value? == 21
            player.return_bet hand
          else
            player.lose_bet hand
          end
        end
      end

    # everyone wins if the dealer goes bust
    elsif dealer.hands[0].is_busted?
      players.each do |player|
        player.hands.each do |hand|
          if not hand.is_busted?
            player.win_bet hand
          end
        end
      end

    # dealer does not have blackjack and he is not busted.
    else
      players.each do |player|
        player.hands.each do |hand|
          if not player.is_dealer? and not hand.is_busted?
            if hand.value? > dealer.hands[0].value?
              player.win_bet hand
            elsif hand.value? < dealer.hands[0].value?
              player.lose_bet hand
            else
              player.return_bet hand # dealer and player are tied
            end
          end
        end
      end
    end
    gets
    print_round_summary
  end

  def print_round_summary
    # print a summary
    clear_console
    puts "-------------------- Round Summary ----------------------"
    print_state_of_game(bet = false, only_first_card = false, show_val = true)
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