#!/usr/bin/ruby

require 'cards'
require 'players'

def prompt(*args)
    print(*args)
    gets.chomp
end

def enterToContinue
	print "Press enter to continue..."
	gets
	print "\n"
end

# keeps prompting until number >= 1 (a Natural Number) is returned
def promptForNaturalNumber(ask, reprompt)
	result = prompt(ask).to_i
	while result <= 0
		result = prompt(reprompt).to_i
	end
end

def clearConsole
	system "clear" or system "cls"
end

class Game
	# list of players, total number of players, and number of current player
	attr_accessor :players, :num_players, :cur_player, :dealer, :gameOver, :deck

	def initialize
		puts "Welcome to Blackjack!"
		enterToContinue

		# # get the number of players
		# num_players = prompt("How many people are playing?\n").to_i
		# while num_players <= 0
		# 	num_players = prompt("Enter a number greater than 0: ").to_i
		# end

		# # get the initial cash
		# start_cash = 
		# 	prompt("How much money should everyone start with?\n").to_i

		# while num_players <= 0
		# 	start_cash = prompt("Enter a number greater than 0: ").to_i
		# end

		num_players = 1
		start_cash = 1000

		# create the players
		self.players = [];
		for i in 1..num_players
			self.players << Player.new(i, start_cash)
		end

		# create the dealer, add to players
		self.dealer = Dealer.new
		self.players << self.dealer

		while true
			self.playRound
		end
	end

	def playRound
		self.deck = Deck.new

		# reset players' cards, have them make bets, and then deal
		for i in 0..1
			for player in players
				if i == 0:
					clearConsole()
					# clear the players' cards and have them make bets
					player.resetCards
					if not player.isDealer
						player.makeBet
					end
				end
				player.draw(deck)
			end
		end

		for player in players
			clearConsole()
			player.takeTurn(self)
		end

		# everyone wins
		if dealer.busted
			for player in players
				if not player.busted
					player.winBet
				end
			end
		else
			for player in players
				if not player.isDealer
					if not player.busted
						if player.valueOfCards > dealer.valueOfCards
							player.winBet
						elsif player.valueOfCards < dealer.valueOfCards
							player.loseBet
						end
					end
				end
			end
		end

		printRoundSummary
	end

	def printRoundSummary
		# print a summary
		clearConsole()
		puts "---------- Round Summary ------------"
		for player in players
			puts player.toString
		end
		puts "Press enter to continue to next round"
		gets
	end

	# a function to display the current player's cards and the dealer's
	def printCurrentCards(player)
		print "Dealer's cards: ", self.dealer.cardsToString, "\n"
		print "Your cards: ", player.cardsToString, "\n"
		print "\n"
	end

end

Game.new