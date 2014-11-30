module RpsRpg

  class Actor

    STATS = [:maxhp, :maxmp, :atk, :arm, :stealth, :speed, :magic]

    attr_reader :spells, :equipment, :level, :hp, :mp
    attr_accessor :abi_damage, :abi_boost, :jobclass, :damage, :fight_action

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
      @states = []
      @damage = 0
      @fight_action = nil
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

    def learn_spell(spell)
      spell.user = self
      @spells << spell
    end

    def apply_damage(damage)
      if self.arm >= 0
        damage -= damage * arm / (arm + 32)
      else
        damage += damage * arm.abs / 100
      end
      @damage += damage
      @damage /= 2 if @fight_action == :defend
      self.hp -= damage
    end

    def apply_state(state)
      @states << state
      state.ability_change.each do |stat, val|
        amount = self.send("base_#{stat}".to_sym) * val / 100
        @abi_boost[stat] += amount
      end
    end

    def remove_state(state)
      @states.delete(state)
      state.ability_change.each do |stat, val|
        amount = self.send("base_#{stat}".to_sym) * val / 100
        @abi_boost[stat] -= amount
      end
    end

    def check_states
      @states.each do |state|
        self.deal_damage(state.slip_damage)
        state.tick
        remove_state(state) if state.turn == 0
      end
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
