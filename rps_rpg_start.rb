require_relative "actor.rb"
require_relative "game.rb"
require_relative "humanplayer.rb"
require_relative "item.rb"
require_relative "jobclass.rb"
require_relative "spell.rb"
require_relative "town.rb"
require 'colorize'

if $PROGRAM_NAME == __FILE__
  print "Player 1's name please: "
  player1 = RpsRpg::HumanPlayer.new(gets.chomp)
  print "Player 2's name please: "
  player2 = RpsRpg::HumanPlayer.new(gets.chomp)
  game = RpsRpg::Game.new(player1,player2)
  game.run
end
