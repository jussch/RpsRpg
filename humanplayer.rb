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
      [@fame * (100 - 100 * @actor.stealth / ( 50 + @actor.stealth ) ) / 100, 100].max
    end

    def apply_damage(damage)
      @actor.apply_damage(damage)
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

    end

    def get_townaction(town)
      begin
        system('clear')
        puts render_town_pic(town)
        puts render_status
        puts render_t_actions
        input = gets.chomp.strip.to_i

        case input
        when 1


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
      str += "Your Gold: #{@gold}".ljust(26) + "Your Visibility: #{self.visibility}%\n"
      str += "---------------------MAIN----------------------------\n".light_black
      str += "1) Shop: Buy equipment.\n"
      str += "2) Witch: Buy spells.\n"
      str += "3) Quest: Complete quests for money, levels, and possible items.\n"
      str += "---------------------RECOVER-------------------------\n".light_black
      str += "4) Inn: Restore your HP and MP.\n"
      str += "5) Doctor: Restore your ability damage.\n"
      str += "---------------------TERTIARY------------------------\n".light_black
      str += "6) Train: Level Up.\n"
      str += "7) Work: Gain Money.\n"
      str += "---------------------FIGHT!--------------------------\n".light_black
      str += "8) Fight: Look for your enemy, given a #{@enemy.visibility}% chance to do so.\n"
    end

    def render_town_pic(town)
      "       #{town.name}    \n"+
      "             |   _   _ \n"+
      "       . | . x .|.|-|.|\n"+
      "    |\ ./.\-/.\-|.|.|.|\n"+
      " ~~~|.|_|.|_|.|.|.|_|.|~~~"
    end

    def render_shop_pic(shop)
      "               #{shop} \n"+
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
