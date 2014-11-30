module RpsRpg

  class State

    attr_reader :effect, :turn, :name

    def initialize(name, effect = {})
      default = {
        ability_change: {}
        slip_damage: nil
        duration: 5
      }
      @name = name
      @effect = default.merge(effect)
      @turn = @effect[:duration]
    end

    def slip_damage
      @effect[:slip_damage]
    end

    def ability_change
      @effect[:ability_change]
    end

    def tick
      @turn -= 1
    end

  class Spell

    attr_accessor :user

    def initialize(power, cost, options = {})
      @user = nil
      @base_power = power
      @base_cost = cost
      default = {
        ability_damage: {},
        ability_boost: {},
        states: []
      }
      @options = default.merge(options)
    end

    def power
      @base_power * (@user.magic + 100) / 100
    end

    def cost
      Integer( @base_cost * (1.0 - @user.magic / (@user.magic + 100)) )
    end

    def ability_damage
      @options[:ability_damage]
    end

    def ability_boost
      @options[:ability_boost]
    end

    def cast(target)
      target.apply_damage(power)
      @options[:states].each do |state|
        target.apply_state(state)
      end
      ability_damage.each do |stat, damage|
        target.abi_damage[stat] += damage
      end
      ability_boost.each do |stat, boost|
        target.abi_boost[stat] += boost
      end
      @user.mp -= cost
    end

  end

end
