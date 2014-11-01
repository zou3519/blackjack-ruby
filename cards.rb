# contains Card and Deck

class Card
	RANKS = %w(2 3 4 5 6 7 8 9 10 Jack Queen King Ace)
	SUITS = %w(Clubs Diamonds Hearts Spades)

	attr_accessor :rank, :suit, :value

	# initialize card based on id, a number between 1 and 52
	def initialize(id)
		rank_index = id % 13
		self.rank = RANKS[rank_index]
		self.suit = SUITS[id % 4]

		# now, determine the value.
		if (rank_index <= 8)
			self.value = rank_index + 2
		elsif rank_index <= 11
			self.value = 10
		else # we have an ace
			# an ace is an 11 or a 1, but this will be handled elsewhere
			self.value = 11 
		end	
	end

	def toString
		return self.rank + " of " + self.suit
	end
end

class Deck
	attr_accessor :cards, :hascards
	
	# initialize by shuffling deck	
	def initialize
		self.cards = []
		for i in 0..51
			cards << Card.new(i)
		end
		self.cards.shuffle! # shuffle with ruby's shuffle function
	end

	def draw
		return self.cards.pop
	end

	def hascards?
		return !self.cards.empty?
	end
end