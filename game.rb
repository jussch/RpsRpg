module RpsRpg

  JOBCLASS_SELECTION_SIZE = 4

  class Game

    def initialize(player1, player2)
      player1.enemy = player2
      player2.enemy = player1
      @players = [player1, player2]
      setup_players
      @town = nil #setup_town <--------NOT IMPLEMENTED
    end

    def setup_players
      selection = []
      JOBCLASS_SELECTION_SIZE.times { selection << JobClass.generate_random }
      @players.each do |player|
        player.actor = Actor.new
        jobclass = player.get_jobclass(selection)
        player.actor.jobclass = jobclass
        player.actor.hp = player.maxhp
        player.actor.mp = player.maxmp
      end
    end

    def run
      until game_over?
        #town_phase <--------NOT IMPLEMENTED
        fight_phase
      end
      if @players.first.lost? && !@players.last.lost?
        puts "#{@players.last.name} wins!".blink
      elsif @players.last.lost? && !@players.first.lost?
        puts "#{@players.first.name} wins!".blink
      else
        puts "Tie!"
      end
    end

    def game_over?
      @players.one? { |player| player.lost? }
    end

    def town_phase
      loop do
        @players.each do |player|
          action = player.get_townaction
          #------ <--------NOT IMPLEMENTED
          #------ <--------NOT IMPLEMENTED
        end
      end
    end

    def fight_phase
      loop do
        @players.each do |player|
          system('clear')
          puts "#{player.name}'s turn, please hand them the keyboard."
          puts ".".blink
          gets.chomp
          player.get_fightaction
        end

        system('clear')
        @players.each do |player|
          if player.fight_action.first == :parry &&
             player.enemy.fight_action.first == :strike
            player.enemy.fight_action = [:got_parried, 0]
            player.fight_action = [:did_parry, 0]
          end
        end

        ordered_players = @players.sort { |a,b| b.speed <=> a.speed }
        ordered_players.each do |player|
          action = player.fight_action.first
          effect = player.fight_action.last
          enemy_action = player.enemy.fight_action.first
          case action
          when :strike
            player.enemy.apply_damage(effect)
            player.actor.abi_boost[:atk] += enemy_action == :defend ? 10 : 5
          when :defend
            effect *= 4 if enemy_action == :parry
            player.enemy.apply_damage(effect)
          when :did_parry
            player.actor.abi_boost[:atk] += 10
            player.actor.abi_boost[:arm] += 10
          when :got_parried
            player.actor.abi_damage[:atk] += 10
            player.actor.abi_damage[:arm] += 10
          when :cast
            spell = player.actor.spells[effect]
            action = spell.name
            if spell.scope == :enemy
              spell.cast(player.enemy)
            elsif spell.scope == :self
              spell.cast(player)
            else
              raise "Improper spell scope?"
            end
          end
          puts "#{player.name} used #{action} and dealt #{player.enemy.actor.damage}!"
          sleep(1)

          player.actor.check_states
          if player.actor.damage > 0
            puts "#{player.name} took #{player.actor.damage} slip damage."
            sleep(1)
          end

          player.actor.damage = 0
          player.enemy.actor.damage = 0
          return if game_over?
        end
        puts ".".blink
        gets.chomp
      end
    end

  end

end
