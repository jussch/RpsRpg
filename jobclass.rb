module RpsRpg

  class JobClass

    BASE_ABI = {
      maxhp: 300,
      maxmp: 100,
      atk: 24,
      armor: 24,
      stealth: 24,
      speed: 24,
      magic: 24
    }

    BASE_ABI_GROWTH = {
      maxhp: 31,
      maxmp: 11,
      atk: 6,
      armor: 6,
      stealth: 4,
      speed: 4,
      magic: 6
    }

    ABI_MODIFIERS = {
      # -- Percentile Values ( 100 = normal )
      primary: 150,
      secondary: 140,
      tertiary: 125,
      weakness: 80,
      weakness2: 70
    }

    def self.generate_random
      modifier = Hash.new
      abilities = BASE_ABI.keys.sample(5)
      ABI_MODIFIERS.keys.each_with_index do |ord, index|
        modifier[ord] = abilities[index]
      end
      JobClass.new(modifier)
    end

    attr_reader :name

    def initialize(modifiers)
      @base = BASE_ABI.dup
      @base.each { |k,v| @base[k] = v + rand(4) - 2}
      @growth = BASE_ABI_GROWTH.dup
      modifiers.each do |ord, ability|
        @base[ability] *= ABI_MODIFIERS[ord]
        @base[ability] /= 100
        @growth[ability] *= ABI_MODIFIERS[ord]
        @growth[ability] /= 100
      end
      @name = generate_name
      @mod = modifiers
    end

    def generate_name
      str = ""
      3.times { str += ("A".."Z").to_a.sample }
      str
    end

    def generate_curve(ability)
      array = []
      99.times do |i|
        array << @base[ability] + @growth[ability] * i
      end
      array
    end

    def maxhp
      generate_curve(:maxhp)
    end

    def maxmp
      generate_curve(:maxmp)
    end

    def atk
      generate_curve(:atk)
    end

    def arm
      generate_curve(:armor)
    end

    def stealth
      generate_curve(:stealth)
    end

    def speed
      generate_curve(:speed)
    end

    def magic
      generate_curve(:magic)
    end

    def get_color(stat)
      case @mod.key(stat)
      when :primary
        :light_green
      when :secondary, :tertiary
        :green
      when :weakness
        :red
      when :weakness2
        :light_red
      else
        :default
      end
    end

    def render
      string_arr = [@name.blue + ":".blue,"----------"]
      @base.keys.each do |stat|
        stat_str = "#{stat.to_s.capitalize}    "[0,7]
        color = get_color(stat)
        string_arr << "#{stat_str}: #{self.send(stat)[1]}".colorize(color)
      end
      string_arr
    end

  end

end
