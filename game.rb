module RpsRpg

  JOBCLASS_SELECTION_SIZE = 4

  class Game

    def initialize(player1, player2)
      @players = [player1, player2]
      setup_players
      @town = setup_town
    end

    def setup_players
      selection = []
      JOBCLASS_SELECTION_SIZE.times { selection << JobClass.generate_random }
      @players.each do |player|
        player.actor = Actor.new
        jobclass = player.get_jobclass(selection)
        player.actor.jobclass = jobclass
      end
    end

    def run
      until game_over?
        town_phase
        fight_phase
      end
      if @players.first.lost?
        puts "#{players.last.name} wins!"
      else
        puts "#{players.first.name} wins!"
      end
    end

    def game_over?
      @players.one { |player| player.lost? }
    end

    def town_phase
      loop do
        @players.each do |player|
          action = player.get_townaction
          #------
          #----
        end
      end
    end

  end

end
