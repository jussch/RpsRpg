module RpsRpg

  class Actor

    STATS = [:maxhp, :maxmp, :atk, :arm, :stealth, :speed, :magic]

    attr_reader :spells, :equipment, :level, :hp, :mp, :states
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

    def self_spells
      @spells.select { |spell| spell.scope == :self }
    end

    def learn_spell(spell)
      spell.user = self
      @spells << spell
    end

    def apply_damage(damage)
      raw_damage = damage
      if self.arm >= 0
        damage -= damage * arm / (arm + 64)
      else
        damage += damage * arm.abs / 100
      end
      @damage += damage
      @damage /= 2 if @fight_action == :defend
      @damage = raw_damage if raw_damage < 0
      self.hp -= @damage
    end

    def apply_state(state)
      @states << state
      state.ability_change.each do |stat, val|
        amount = self.send(stat) * val / 100
        state.stolen_stats[stat] = amount
        @abi_boost[stat] += amount
      end
    end

    def remove_state(state)
      @states.delete(state)
      state.ability_change.each do |stat, val|
        amount = state.stolen_stats[stat]
        @abi_boost[stat] -= amount
      end
    end

    def check_states
      @states.each do |state|
        if state.slip_damage != nil
          self.hp -= state.slip_damage
        end
        state.tick
        remove_state(state) if state.turn <= 0
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
