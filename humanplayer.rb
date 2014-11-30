class InvalidInputError < StandardError
end

module RpsRpg

  class HumanPlayer

    STATS = [:maxhp, :maxmp, :hp, :mp, :atk, :arm, :stealth, :speed, :magic]

    attr_accessor :actor, :enemy, :fight_action
    attr_reader :name

    def initialize(name = 'Billy Bob')
      @actor = nil
      @name = name
      @fight_action = nil
      @enemy = nil
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
      length = [self.name.length, 6].max
      str =  "      " + self.name.rjust(length)      + " || #{@enemy.name}\n"
      str += "HP:   " + self.hp.to_s.rjust(length)   + " || #{@enemy.hp}\n"
      str += "MP:   " + self.mp.to_s.rjust(length)   + " || #{@enemy.mp}\n"
      str += "ATTK: " + self.atk.to_s.rjust(length)  + " || #{@enemy.atk}\n"
      str += "ARMR: " + self.arm.to_s.rjust(length)  + " || #{@enemy.arm}\n"
      str += "SPEED:" + self.speed.to_s.rjust(length)+ " || #{@enemy.speed}\n"
    end

    def render_actions
      str =  "Actions:\n"
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
        print render_actions
        input = gets.chomp.strip.to_i

        case input
        when 1
          damage = self.atk
          action = :strike
        when 2
          damage = self.atk / 2
          action = :defend
        when 3
          damage = 0
          action = :parry
        else
          if input.between?(4, 3+@actor.spells.size)
            action = :cast
            damage = @actor.spells[input-4]
          else
            raise InvalidInputError.new "Improper Input"
          end
        end

        @actor.fight_action = action
        @fight_action = [action, damage]
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
