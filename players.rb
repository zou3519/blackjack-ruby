DEALER_ID = 0 # player id for dealer

class Player
	HIT = %w(h hit)	
	STAND = %w(st stand)
	DOUBLE_DOWN = ["dd", "double down"]
	SPLIT = %w(sp, split)

	OPTIONS = HIT | STAND | DOUBLE_DOWN | SPLIT

	SEP = "\n| "
	ASK = "What would you like to do?"  + SEP+
			"stand: enter 'st' or 'stand'"  + SEP+
			"hit: enter 'h' or 'hit'" + SEP+
			"double down: enter 'dd' or 'double down'"  +	"\n" +
			"Type your option: "
	WRONG_INPUT = "I can't recognize your input. Try again: "

	attr_accessor :id 		# player identifier
	attr_accessor :bet		# player's bet for the round
	attr_accessor :cards 	# what cards you  have
	attr_accessor :busted  	# are you busted?
	attr_accessor :turnOver # is your turn over?
	attr_accessor :cash 	# how much cash do you have?

	def initialize(id, cash)
		self.id = id
		self.cash = cash
		self.resetCards
	end

	def makeBet
		puts("Player " + self.id.to_s + " you currently have $" + self.cash.to_s)

		# get the number of players
		self.bet =  prompt("Player " + self.id.to_s + " make a bet!\n").to_i
		while self.bet <= 0 or self.bet > self.cash
			self.bet = prompt(
				"You can make bets of between $1 and $" + self.cash.to_s + ": ").to_i
		end
	end

	def winBet
		self.cash += self.bet
	end

	def loseBet
		self.cash -= self.bet
	end

	# the main loop of a player's turn
	def takeTurn(game)
		clearConsole()
		print ("Player " + self.id.to_s + "'s turn.\n")
		self.turnOver = false

		while not self.turnOver

			print (self.toString + "\n")
			# ask for the input
			option = prompt(ASK)
			print "\n"

			while not OPTIONS.include? option
				option = prompt(WRONG_INPUT)
			end

			# parse the option
			if (HIT.include? option)
				self.draw(game.deck, false)
				self.checkBusted
			elsif (DOUBLE_DOWN.include? option)
				puts "You chose double down!"
				if self.cash >= self.bet*2
					self.bet = self.bet*2
					self.draw(game.deck, false)
					self.checkBusted
					puts self.toString
					enterToContinue()
					self.turnOver = true
				else
					puts "Insufficient funds."
					enterToContinue()
				end
			elsif (STAND.include? option)
				puts "You decided to stand."
				self.turnOver = true
				enterToContinue()
			else
				# never actually reached
			end
		end
	end

	def resetCards
		@num_aces = 0
		self.cards = []
		self.busted = false
	end

	# draw a card from the deck
	def draw(deck, silent = true)
		card = deck.draw 
		cards << card 
		if card.rank.eql? "Ace"
			@num_aces += 1
		end
		if not silent
			print (card.toString + " drawn. (Press enter to continue)")
			gets
			print "\n"
		end
	end

	def checkBusted
		if valueOfCards > 21
			puts "Busted!"
			enterToContinue()
			self.loseBet
			self.busted = true
			self.turnOver = true
		end
	end

	# returns the value of all the cards.
	# sets all the aces to 1's or 11's such that
	# we get the maximum value 21 and under, if possible,
	# otherwise the minimum value over 21.
	def valueOfCards
		value = 0  
		for card in cards
			value += card.value
		end

		counter = 0
		while value > 21 && counter < @num_aces
			counter += 1
			value -= 10
		end
		return value
	end

	def cardsToString
		s = ""
		for card in cards
			if not s.eql? ""
				s += ", "
			end
			s += card.toString
		end
		return s
	end
	def toString
		sep = "\n| "
		s = "Player " + self.id.to_s + sep + "$" + self.cash.to_s + sep 
		s += "Bet: " + self.bet.to_s + sep
		if self.busted
			s += "Value of cards: busted" + sep
		else
			s += "Value of cards: " + self.valueOfCards.to_s + sep
		end
		s += self.cardsToString + "\n" 
	end

	def isDealer
		return self.id == DEALER_ID
	end
end

class Dealer < Player
	DEALER_TURN = "It is the dealer's turn.\n"

	def initialize
		self.resetCards
		self.id = DEALER_ID
	end

	def takeTurn(game)
		puts DEALER_TURN
		self.turnOver = false

		while not self.turnOver
			print self.toString + "\n"
			if self.valueOfCards >= 17 and !self.busted
				self.turnOver = true
			else
				# dealer will hit until he gets >= 17 points
				# parse the option
				self.draw(game.deck, false)
				self.checkBusted
			end
		end

		print self.toString + "\n"
		puts "Dealer ends his turn (Press enter to continue)"
		gets
	end

	def toString
		sep = "\n| "
		s = "Dealer" + sep
		if self.busted
			s += "Value of cards: busted" + sep
		else
			s += "Value of cards: " + self.valueOfCards.to_s + sep
		end
		s += self.cardsToString + "\n" 
	end
end