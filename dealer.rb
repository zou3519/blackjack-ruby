require 'deck'
require 'prompt'

DEALER_ID = 0 # player id for dealer

# the dealer is just a very special player
class Dealer < Player
	DEALER_TURN = "It is the dealer's turn.\n"

	def initialize
		self.reset_cards
		self.id = DEALER_ID
	end

	# dealer makes no bets
	def make_initial_bet ; end
	def win_bet(hand) ; end
	def lose_bet(hand) ; end

	def take_turn(game)

    self.hands.each do |hand|
      while not hand.finished_playing
        # print the state
				clear_console
				puts DEALER_TURN
        game.print_state_of_game

        # ask for the input
		    if hand.value? >= 17 and not hand.is_busted?
					hand.end_play!
				else
					# dealer will hit until he gets >= 17 points
					# parse the option
					self.draw(game.deck, hand, silent = false)
					self.check_busted hand
				end
      end
    end
    puts "The dealer ends his turn."
    wait_for_newline
  end


	# def to_string
	# 	sep = "\n| "
	# 	s = "Dealer" + sep
	# 	if self.busted
	# 		s += "Value of cards: busted" + sep
	# 	else
	# 		s += "Value of cards: " + self.value_of_cards.to_s + sep
	# 	end
	# 	s += self.cards_to_string + "\n" 
	# 	return s
	# end

  def to_string_short
    sep = " | "
    result = "Dealer\n"
    hands.each do |hand|
      result += "\\ "
      if hand.is_busted?
        result += "<busted>" + sep
      end
      result += "hand: "
      result += hand.to_string + "\n"
    end
    return result
  end
end