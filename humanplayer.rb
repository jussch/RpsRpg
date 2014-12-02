class InvalidInputError < StandardError
end

module RpsRpg

  class HumanPlayer

    STATS = [:maxhp, :maxmp, :hp, :mp, :atk, :arm, :stealth, :magic, :speed]

    attr_accessor :actor, :enemy, :fight_action, :gold, :fame
    attr_reader :name

    def initialize(name = 'Billy Bob')
      @actor = nil
      @name = name
      @fight_action = nil
      @enemy = nil
      @gold = 1000
      @fame = 0
    end

    def visibility
      [@fame * (100 - 100 * @actor.stealth / ( 50 + @actor.stealth ) ) / 100, 100].min
    end

    def apply_damage(damage)
      @actor.apply_damage(damage)
    end

    def acquire(item)
      if @actor.equipment[item.type].nil?
        @actor.equipment[item.type] = item
      else
        begin
          current_item = @actor.equipment[item.type]
          puts "You currently have equipped: #{current_item}"
          puts "\tin the #{item.type} slot, would you rather have:"
          puts "#{item} equipped?"
          print "(Y/N): "
          input = gets.chomp.strip.upcase

          if input == "Y"
            @actior.equipment[item.type] = item
            puts "You equipped the #{item.name}!"
            puts "[Press Enter]".blink
            gets.chomp
          elsif input == "N"
            nil
          else
            raise InvalidInputError.new "Not Y or N"
          end

        rescue InvalidInputError => e
          puts "Error: #{e.message}"
          sleep(1)
          retry
        end
      end
    end

    def get_jobclass(selection)
      puts "#{@name}, choose a class:"

      full_render = Array.new
      selection.size.times do |i|
        render = selection[i].render
        render[0] = "[#{i}] " + render[0]
        (0...render.size).to_a.each do |j|
          if full_render[j].nil?
            full_render[j] = render[j]
          else
            full_render[j] += "\t" + render[j]
          end
        end
      end
      puts full_render.join("\n")

      input = Integer(gets.chomp)
      selection[input]
    end

    def enter_shop_sequence(name, shop)
      begin
        system('clear')
        puts render_shop_pic(name)
        puts render_board([self])
        puts render_town_stats
        puts "To Buy:"
        i = 1
        shop.each do |item|
          gold_txt = item.gold_cost == 0 ? "" : "#{item.gold_cost} Gold: ".rjust(11).light_yellow
          puts "#{i}) " + gold_txt + "#{item}"
          i += 1
        end
        puts "#{i}) -- Return to main town menu.\n\n"
        print "#{@name}, please input what you desire: "
        input = gets.chomp.strip.to_i

        case input
        when (1..shop.size)
          item = shop[input - 1]
          raise InvalidInputError.new "Not enough money" if item.gold_cost > @gold
          return item
        when (shop.size + 1)
          return nil
        else
          raise InvalidInputError.new "Invalid Input"
        end

      rescue InvalidInputError => e
        puts "Error: #{e.message}"
        sleep(1)
        retry
      end
    end

    def get_townaction(town)
      begin
        system('clear')
        puts render_town_pic(town)
        puts render_board([self])
        puts render_status
        puts render_town_stats
        puts render_t_actions
        print "\t#{@name}, please input your action: "
        input = gets.chomp.strip.to_i

        case input
        when 1
          item = enter_shop_sequence("Blacksmith", town.shop)
          raise InvalidInputError.new "No item bought." if item.nil?
          acquire(item.dup)
        when 2
          spell = enter_shop_sequence("Wizard's Hut", town.witch)
          raise InvalidInputError.new "No spell bought." if spell.nil?
          @actor.learn_spell(spell.dup)
          puts "You learned #{spell.name}!"
          puts "[Press Enter]".blink
          gets.chomp
        when 3
          quest = enter_shop_sequence("Tavern", town.quests)
          raise InvalidInputError.new "No quests taken." if quest.nil?
          quest.do_quest(self)
          town.quests.delete(quest)
          @fame += 10
          puts "You completed #{quest.name}!"
          puts "[Press Enter]".blink
          gets.chomp
        when 4
          @actor.hp = @actor.maxhp
          @actor.mp = @actor.maxmp
          puts "You restored your HP and MP!"
          puts "[Press Enter]".blink
          gets.chomp
        when 5
          @actor.abi_damage = Hash.new(0)
          puts "You restored your abilities!"
          puts "[Press Enter]".blink
          gets.chomp
        when 6
          @actor.level_up
          puts "You've leveled up!"
          puts "[Press Enter]".blink
          gets.chomp
        when 7
          @gold += 200
          puts "You gained 200 gold!"
          puts "[Press Enter]".blink
          gets.chomp
        when 8
          puts "Equipment:"
          @actor.equipment.each { |k,v| puts "#{k.capitalize} Slot: #{v}"}
          puts "\nSpells:"
          @actor.spells.each { |spell| puts "#{spell}" }
          puts # Empty Line----
          puts "[Press Enter]".blink
          gets.chomp
        when 9
        else
          raise InvalidInputError.new "Invalid Input."
        end

        input

      rescue InvalidInputError => e
        puts "Error: #{e.message}"
        sleep(1)
        retry
      end
    end

    def get_fightaction
      begin
        system('clear')
        puts render_board
        puts render_status
        print render_f_actions
        input = gets.chomp.strip.to_i

        case input
        when 1
          effect = 5
          action = :strike
        when 2
          effect = 5
          action = :defend
        when 3
          effect = 0
          action = :parry
        when (4+@actor.spells.size)
          effect = 100 - self.visibility
          action = :escape
        else
          if input.between?(4, 3+@actor.spells.size)
            action = :cast
            effect = @actor.spells[input-4]
            raise InvalidInputError.new "Not Enough Mana" if @actor.mp < effect.cost
          else
            raise InvalidInputError.new "Improper Input"
          end
        end

        @actor.fight_action = action
        @fight_action = [action, effect]
      rescue InvalidInputError => e
        puts "Error: #{e.message}"
        sleep(1)
        retry
      end
    end

    def lost?
      @actor.hp <= 0
    end

    STATS.each do |stat|
      HumanPlayer.class_eval(
      "def #{stat};
        @actor.#{stat};
       end;")
    end

    def render_board(player_arr = [self, @enemy])
      length = [self.name.length, 7].max
      printed_stats = STATS.drop(2)
      str =  self.name.rjust(length + 6).light_cyan  + " || "+"#{@enemy.name}\n".light_cyan
      str += "------------------------\n".light_black
      printed_stats.each do |stat|
        str += "------------------------\n".light_black if stat == :stealth || stat == :atk
        str += "#{stat.to_s.upcase}:".ljust(8)
        player_arr.each do |player|
          str += " || " if player == @enemy
          stat_value = player.send(stat)
          if stat == :hp || stat == :mp
            max_value = player.send("max#{stat}".to_sym)
            case stat_value.fdiv(max_value)
            when (0.7..1.0)
              color = stat == :hp ? :green : :blue
            when (0.3...0.7)
              color = stat == :hp ? :light_yellow : :cyan
            when (0.0...0.3)
              color = stat == :hp ? :red : :light_black
            end
          else
            base_value = player.actor.send("base_#{stat}".to_sym)
            case stat_value <=> base_value
            when -1
              color = :light_red
            when 0
              color = :default
            when 1
              color = :light_green
            end
          end
          if player == @enemy
            str += stat_value.to_s.ljust(length - 2).colorize(color)
          else
            str += stat_value.to_s.rjust(length - 2).colorize(color)
          end
        end
        str += "\n"
      end
      str += "\n"
    end

    def render_status
      str = "\tYour status:\n"
      if @actor.states.size == 0
        str += "Normal\n"
      else
        @actor.states.each { |state| str += "#{state}\n"}
      end
      str + "\n"
    end

    def render_town_stats
      str =  "Your Level: #{@actor.level}\n".cyan
      str += "Your Gold: #{@gold}\n".cyan
      str += "Your Visibility: #{self.visibility}%\n".cyan
    end

    def render_f_actions
      str =  "Actions:\n".yellow
      str += "1) Strike: Deal #{self.atk} damage, gain 5 ATK.\n"
      str += "2) Defend: Deal #{self.atk/2} damage, take 50% damage, gain 5 ARM.\n"
      str += "3) Parry: Negate enemy Strike, stealing ATK and ARM if it succeeds.\n"
      spells = @actor.spells
      spells.size.times { |i| str += "#{i+4}) Cast #{spells[i]}\n"}
      str += "#{spells.size + 4}) Escape: #{100 - self.visibility}% chance to run to a nearby town and escape from your foe.\n"
      str += "\n  #{@name}, choose your action: "
    end

    def render_t_actions
      str =  "Town Actions:\n".yellow
      str += "---------------------MAIN----------------------------\n".light_black
      str += "1) Shop: Buy equipment.\n"
      str += "2) Witch: Buy spells.\n"
      str += "3) Quest: Complete quests for money, levels, and possible items.\n"
      str += "---------------------RECOVER-------------------------\n".light_black
      str += "4) Inn: Restore your HP and MP.\n"
      str += "5) Doctor: Restore your ability damage.\n"
      str += "---------------------TERTIARY------------------------\n".light_black
      str += "6) Train: Level Up.\n"
      str += "7) Work: Gain 200 gold.\n"
      str += "8) Inspect Yourself: View your spells and equipment.\n"
      str += "---------------------FIGHT!--------------------------\n".light_black
      str += "9) Fight: Look for your enemy, given a #{@enemy.visibility}% chance to do so.\n"
    end

    def render_town_pic(town)
      "       #{town.name}    \n".bold.light_blue +
      "             |   _   _ \n"+
      "       . | . x .|.|-|.|\n"+
      "    |\\ ./.\\-/.\\-|.|.|.|\n"+
      " ~~~|.|_|.|_|.|.|.|_|.|~~~"
    end

    def render_shop_pic(shop)
      "               #{shop} \n".bold.cyan +
      "                           ::\n"+
      "                          '>'\n"+
      "               .:::::::::>|>'>|.\n"+
      "             ./^               ^':.\n"+
      "           ./^                    `\\.\n"+
      "          `~''->>>:::....::::>>>|---'~\n"+
      "             '                  '\n"+
      "             '  ..   ....   ..  '       ..:|>\n"+
      "       :     '  ''   '^^^   '`> '::|>' ^'  '\n"+
      " -''~ ~ ^'^'^       '~   '> ':> `> '    `> '\n"+
      "  '> ' ' '>`>       '>   '| ^^  '>    ' '>.|:\n"+
      "..||.|: : >>>'------''----'-----'~~~~~^^^^^^^\n"+
      "```        |.. ..'.|:\n"+
      "           .|'^^`'`^`\n"
    end

  end

end
