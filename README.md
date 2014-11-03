Blackjack in Ruby
=====================

By Richard Zou

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