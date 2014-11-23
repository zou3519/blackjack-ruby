Blackjack in Ruby
=====================

By Richard Zou

Last updated November 2014

Introduction
=====================

A simple command-line blackjack game for multiple players written in
Ruby 1.8.7.  The program inplements the core blackjack rules.  
On a player's turn, he/she may hit until they go over 21.  The
program supports splitting and doubling-down.

Running the program
=====================

Type 

    ruby blackjack.rb

at the command-line.
You will be prompted for a number of human players and the starting
cash for each person.  Follow the instructions on-screen for game play.

Files
=====================

* blackjack.rb - The main file to run
* card.rb - Contains a Card class
* hand.rb - Contains a Hand class, a class for a hand of cards
* deck.rb - Contains a Deck class
* player.rb - Contains a Player class, a class for a player in the game
* dealer.rb - Contains a Dealer class.  The dealer is a player in the game and
inherits from Player
* prompt.rb - Contains command-line printing and prompting utilities
* game.rb - Contains the main Game class and information

Specifications and Errata
====================

The program begins by asking how many players are at the table
and starts each player off with $1000.  Players may make only
integer bets.  Players can choose to hit until they go over 21.
The dealer must hit on 16 and stay on everything above 17.  

Doubling-down is supported and may only occur
when the player has two cards and if the player has enough cash. In addition,
a player who chooses to double down will exactly double his bet and
end his/her turn after receiving one more card.

Splitting may only occur when the player has two cards and a player
may split as much as he/she wishes.

If a player has a blackjack and the value of the dealer's cards is
less than 21, then the player is paid back 3:2.  In this case,
the amount of money the player receives is rounded up if it
is fractional.  If a player has a blackjack and the value of
the dealer's cards is 21 after the dealer takes his/her turn,
then the player only receives his/her bet back.

If a player's cash reserves reach zero, he/she is 
removed from the game.  When all human players are removed from the game,
the game officially ends.  Press ctrl-c to stop the game otherwise.

The program has only been tested under Windows 8.1 running Ruby 1.8.7.
It should work on other operating systems running the same version of Ruby.
