module RpsRpg

  class Actor

    attr_reader :class, :maxhp, :maxmp, :atk, :arm, :res, :stealth, :speed,
                :magic, :spells, :equipment, :level, :hp, :mp
    attr_accessor :abi_damage

    def initialize
      @class = nil
      @maxhp = 0
      @hp = 0
      @maxmp = 0
      @mp = 0
      @atk = 0
      @armor = 0
      @stealth = 0
      @speed = 0
      @magic = 0
      @spells = []
      @equipment = {}
      @level = 1
      @abi_damage = Hash.new(0)
    end

    def hp=(hp)
      @hp = [[hp, 0].max, maxhp].min
    end

    def mp=(mp)
      @mp = [[mp, 0].max, maxmp].min
    end

    def base_stats(symbol)
      n = @class.send(symbol)[@level]
      @equipment.each do |slot,item|
        n += item.send(symbol)
      end
      n
    end

    def base_maxhp
      base_stats(:maxhp)
    end

    def base_maxmp
      base_stats(:maxmp)
    end

    def base_atk
      base_stats(:atk)
    end

    def base_armor
      base_stats(:armor)
    end

    def base_stealth
      base_stats(:stealth)
    end

    def base_speed
      base_stats(:speed)
    end

    def base_magic
      base_stats(:magic)
    end

  end

end
