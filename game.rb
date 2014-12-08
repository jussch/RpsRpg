module RpsRpg

  JOBCLASS_SELECTION_SIZE = 4

  class Game

    def initialize(player1, player2)
      player1.enemy = player2
      player2.enemy = player1
      @players = [player1, player2]
      setup_players
      @town = nil
    end

    def setup_players
      selection = []
      JOBCLASS_SELECTION_SIZE.times { selection << JobClass.generate_random }
      @players.each do |player|
        system('clear')
        player.actor = Actor.new
        jobclass = player.get_jobclass(selection)
        player.actor.jobclass = jobclass
        player.actor.hp = player.maxhp
        player.actor.mp = player.maxmp
      end
    end

    def run
      until game_over?
        town_phase
        next if game_over?
        fight_phase
      end
      if @players.first.lost? && !@players.last.lost?
        puts @players.last.render_board
        puts "#{@players.last.name} wins!".blink
      elsif @players.last.lost? && !@players.first.lost?
        puts @players.first.render_board
        puts "#{@players.first.name} wins!".blink
      else
        puts @players.last.render_board
        puts "Tie!"
      end
    end

    def game_over?
      @players.one? { |player| player.lost? }
    end

    def town_phase
      @town = Town.new
      loop do
        @players.each do |player|
          system('clear')
          puts "#{player.name}'s turn, please hand them the keyboard."
          puts "[Press Enter]".blink.light_white
          gets.chomp
          action = player.get_townaction(@town)
          if action == 9
            if rand(1..100) <= player.enemy.visibility
              puts "#{player.enemy.name} found! Entering combat."
              puts "[Press Enter]".blink.light_white
              gets.chomp
              return
            else
              puts "You failed to find #{player.enemy.name}"
              sleep(1)
            end
          end

        end
        @players.each { |player| player.fame += 35 }
        return if game_over?
      end
    end

    def fight_phase
      loop do
        @players.each do |player|
          system('clear')
          puts "#{player.name}'s turn, please hand them the keyboard."
          puts "[Press Enter]".blink.light_white
          gets.chomp
          player.get_fightaction
        end

        system('clear')
        @players.each do |player|
          if player.fight_action.first == :parry &&
             player.enemy.fight_action.first == :strike
            player.enemy.fight_action = [:got_parried, 10]
            player.fight_action = [:did_parry, 10]
          end
        end

        ordered_players = @players.sort { |a,b| b.speed <=> a.speed }
        sleep(0.3)
        puts ordered_players.first.render_board

        ordered_players.each do |player|
          action = player.fight_action.first
          effect = player.fight_action.last
          enemy_action = player.enemy.fight_action.first

          player.actor.check_states
          dam_txt = nil
          escaped = false

          case action
          when :strike

            use_txt = "swung with his weapon"
            damage = player.atk
            if enemy_action == :defend
              effect *= 2
              damage *= 2
              use_txt += " and crushed the defense"
            end
            player.enemy.apply_damage(damage)
            player.actor.abi_boost[:atk] += effect

          when :defend

            damage = player.atk / 2
            use_txt = "guarded up"
            if enemy_action == :parry
              damage *= 6
              use_txt = "expertly " + use_txt
            end
            player.enemy.apply_damage(damage)
            player.actor.abi_boost[:arm] += effect

          when :parry

            use_txt = "fumbled his parry"
            dam_txt = "."

          when :did_parry

            player.actor.abi_boost[:atk] += effect
            player.actor.abi_boost[:arm] += effect
            use_txt = "parried "+"#{player.enemy.name}".light_cyan
            dam_txt = "."

          when :got_parried

            player.actor.abi_damage[:atk] += effect
            player.actor.abi_damage[:arm] += effect
            use_txt = "was parried"
            dam_txt = "."

          when :escape

            if rand(100) < (100 - player.visibility)
              use_txt = "escaped"
              escaped = true
            else
              use_txt = "failed to escaped"
            end
            dam_txt = "."

          when :cast

            spell = effect
            action = spell.name
            use_txt = "cast "+"#{action}".magenta
            if spell.scope == :enemy
              spell.cast(player.enemy)
            elsif spell.scope == :self
              spell.cast(player)
              use_txt += " on themself"
              dam_txt = ", healing for "+"#{-player.actor.damage} HP".green+"!"
            else
              raise "Improper spell scope?"
            end

          end

          if dam_txt.nil?
            dam_txt = ", dealing "+"#{player.enemy.actor.damage} damage".light_red+"!"
          end

          puts "#{player.name} ".light_cyan + use_txt + dam_txt
          sleep(0.3)

          player.actor.states.each do |state|
            next if state.slip_damage.nil?
            puts "#{player.name}".light_cyan+" took"+
                " #{state.slip_damage}".red+
                " #{state.name}".yellow+" damage."
          end

          player.actor.damage = 0
          player.enemy.actor.damage = 0
          player.fame = [player.fame - 25, 0].max
          return if game_over?
          if escaped
            puts "[Press Enter]".blink.light_white
            gets.chomp
          end
        end
        puts
        puts ordered_players.first.render_board

        puts "[Press Enter]".blink.light_white
        gets.chomp
      end
    end

  end

end
