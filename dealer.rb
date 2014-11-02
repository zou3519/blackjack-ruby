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
	def make_bet ; end
	def win_bet ; end
	def lose_bet ; end

	def take_turn(game)
		self.turn_over = false

		while not self.turn_over
			clear_console
			puts DEALER_TURN
			game.print_state_of_game
			#print (self.to_string + "\n")
			if self.value_of_cards >= 17 and !self.busted
				self.turn_over = true
			else
				# dealer will hit until he gets >= 17 points
				# parse the option
				self.draw(game.deck, false)
				self.check_busted
			end
		end

		# print self.to_string + "\n"
		clear_console
		puts DEALER_TURN
		game.print_state_of_game
		puts "Dealer ends his turn (Press enter to continue)"
		gets
	end

	def to_string
		sep = "\n| "
		s = "Dealer" + sep
		if self.busted
			s += "Value of cards: busted" + sep
		else
			s += "Value of cards: " + self.value_of_cards.to_s + sep
		end
		s += self.cards_to_string + "\n" 
		return s
	end

	def to_string_short
    sep = " | "
    result = "Dealer" 
    if self.busted
      result += sep + "busted"
    end
    result += sep +  cards_to_string
    return result
  end
end