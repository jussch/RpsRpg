module RpsRpg

  class Actor

    STATS = [:maxhp, :maxmp, :atk, :arm, :stealth, :speed, :magic]

    attr_reader :spells, :equipment, :level, :hp, :mp
    attr_accessor :abi_damage, :jobclass

    def initialize
      @jobclass = nil
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
      @abi_boost = Hash.new(0)
      get_stat_readers
    end

    def hp=(hp)
      @hp = [[hp, 0].max, maxhp].min
    end

    def level_up
      @level += 1
    end

    def mp=(mp)
      @mp = [[mp, 0].max, maxmp].min
    end

    def base_stats(symbol)
      n = @jobclass.send(symbol)[@level]
      @equipment.each do |slot,item|
        n += item.send(symbol)
      end
      n
    end

    def get_stat_readers
      STATS.each do |stat|
        Actor.class_eval(
        "def base_#{stat};
           base_stats(:#{stat});
         end;")

        Actor.class_eval(
        "def #{stat};
          base_#{stat} + @abi_boost[:#{stat}] - @abi_damage[:#{stat}];
         end")
      end
    end

  end

end
