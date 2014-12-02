class InvalidInputError < StandardError
end

module RpsRpg

  class HumanPlayer

    STATS = [:maxhp, :maxmp, :hp, :mp, :atk, :arm, :stealth, :magic, :speed]

    attr_accessor :actor, :enemy, :fight_action, :gold
    attr_reader :name

    def initialize(name = 'Billy Bob')
      @actor = nil
      @name = name
      @fight_action = nil
      @enemy = nil
      @gold = 1000
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

    def render_board
      length = [self.name.length, 7].max
      printed_stats = STATS.drop(2)
      str =  self.name.rjust(length + 6).light_cyan  + " || "+"#{@enemy.name}\n".light_cyan
      str += "------------------------\n".light_black
      printed_stats.each do |stat|
        str += "------------------------\n".light_black if stat == :stealth || stat == :atk
        str += "#{stat.to_s.upcase}:".ljust(8)
        [self, @enemy].each do |player|
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

    def render_actions
      str =  "Actions:\n".yellow
      str += "1) Strike: Deal #{self.atk} damage, gain 5 atk.\n"
      str += "2) Defend: Deal #{self.atk/2} damage, take 50% damage, gain 5 armor.\n"
      str += "3) Parry: Negate enemy Strike, stealing if atk and def if it succeeds.\n"
      spells = @actor.spells
      spells.size.times { |i| str += "#{i+4}) Cast #{spells[i]}\n"}
      str += "\n  #{@name}, choose your action: "
    end

    def get_fightaction
      begin
        system('clear')
        puts render_board
        puts render_status
        print render_actions
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

  end

end
