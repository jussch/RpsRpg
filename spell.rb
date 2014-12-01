module RpsRpg

  class State

    attr_reader :effect, :turn, :name

    def initialize(name, effect = {})
      default = {
        ability_change: {},
        slip_damage: nil,
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

    def to_s
      str = "#{@name.capitalize}: "
      ability_change.each do |stat, val|
        if val > 0
          color = :green
        elsif val < 0
          color = :red
        else
          color = :default
        end
        str += "[#{val}% #{stat}] ".colorize(color)
      end
      if slip_damage != nil
        str += "[#{slip_damage} damage/turn] ".red
      end
      str += "-- #{@turn} turns left."
      str
    end

  end

  class Spell

    STATS = [:maxhp, :maxmp, :atk, :arm, :stealth, :speed, :magic]

    O_STATES = [
      ["Burning", {slip_damage: 10}],
      ["Poisoned", {slip_damage: 3, duration: 15}],
      ["Slowed", {ability_change: {speed: -50} }],
      ["Vulnerable", {ability_change: {arm: -100} }],
      ["Weakened", {ability_change: {atk: -60} }],
      ["Revealed", {ability_change: {stealth: -90} }],
      ["Nullified", {ability_change: {magic: -50} }]
    ]

    D_STATES = [
      ["Armor-Up", {ability_change: {arm: 50} }],
      ["Attk-Up", {ability_change: {atk: 50} }],
      ["Speed-Up", {ability_change: {speed: 50} }],
      ["Stealth-Up", {ability_change: {stealth: 50} }],
      ["Magic-Up", {ability_change: {magic: 50} }]
    ]

    ELEMENTS = [:fire, :ice, :water, :thunder, :lightning, :nature, :corpse, :jesus,
                :arcane, :acid, :earth, :truth, :steel, :kush, :wind, :sausage,
                :toast, :love, :bean, :haxor, :greg, :ash, :missile, :obama, :hate,
                :lemon, :nerd, :jock, :time, :satan, :america, :melon, :rice, :crimson,
                :lutefisk, :fuck, :vine, :hydro, :gandhi, :dimension, :booze, :nipple,
                :chocolate, :cream, :mayonaise, :goat, :hitler, :canaidia, :cherry,
                :sauce, :mustard, :finger, :fisting, :arrow, :orange, :asian,
                :privelage, :bandit, :pikachu, :grenade, :rocket, :god, :zues,
                :naked, :nude, :butt, :mountain, :babushka, :sex, :sweat,
                :sensation, :tickle, :kraken, :mega, :omega, :lady, :man,
                :tongue, :"big-toe", :juice, :shit, :lolipop, :bear, :shrek,
                :onion, :swamp, :forest, :tree, :bush, :"thick-bushes", :loneliness,
                :depression, :tears, :bootie, :"ass-wipe", :girl, :boy, :manliness,
                :liver, :kidney, :candy, :nail, :wood, :tooth, :ruby, :python,
                :sanctum, :balls, :shaft, :grease, :mcdonalds, :gyro, :master,
                :hand, :"q-tip", :spear, :ass, :fever, :cold, :disease,
                :einstein, :demon, :lice, :crabs, :stone, :musk, :pounding,
                :dollar, :poor, :divine, :silence, :shrimp, :cage, :dog, :bieber,
                :electricity, :power, :pants, :socks, :fedora, :tophat, :onesie]

    NAMES = [
      "xxx Bolt", "Tornado of xxx", "xxx Spike", "Death by xxx",
      "xxx Bite", "xxxball", "Invoke xxx", "Conjure xxx", "xxx-jutsu",
      "Strike with xxx", "Cascade of xxx", "Bring Forth xxx",
      "Summon xxx", "Inspire xxx", "Resonate xxx", "xxx Blast",
      "xxx Flash", "xxx-aga", "xxx Explosion", "xxx Slam", "xxx of Life",
      "Vortex of xxx", "xxx Strike", "Path of xxx", "Feed xxx", "Avatar of xxx",
      "Avenger of xxx", "Manifest xxx", "xxx Pole", "Shuriken of xxx",
      "Naruto's xxx", "Awesome xxx", "Constrict xxx", "Flow of xxx",
      "Return to xxx", "xxx-ify", "Exemplify xxx", "xxx Party", "Tear Through xxx",
      "xxx, Fuck Yeah!", "xxx Hammer", "xxx Crusher", "xxx Beam", "xxx Ray",
      "xxx Wave", "xxx Powder", "xxx Pump", "xxx Whip", "xxx Smash", "Ultra xxx",
      "Primeval xxx", "xxx Touchdown", "Glimpse Through xxx", "xxx Warp", "xxx Blade",
      "xxx Sauce", "Un-ending xxx", "Tides of xxx", "xxx Quake", "#420xxxIt",
      "Living xxx", "Rhapsody of xxx", "Iron xxx", "Relentless xxx", "P.K. xxx",
      "xxx Rake", "Release the xxx", "Shovel Down xxx", "xxx Slice", "xxx Leakage",
      "xxx Slide", "xxx Door", "xxx Venom", "Spinning xxx", "Spit xxx", "Sea of xxx",
      "xxx's xxx", "xxx from Hell", "Unholy xxx", "Blessed xxx", "The Last xxx",
      "Righteous xxx", "Excrete xxx", "Secret xxx", "Essence of xxx",
      "Smelly xxx", "The xxx-ing", "Feel the xxx", "Disintegrate by xxx",
      "Melt to xxx", "Renegade xxx", "Hail xxx", "xxx Bomb", "Hell-xxx",
      "Delicious xxx", "xxx Destroyer", "xxx Reversal", "From xxx to Dead",
      "xxx Punch", "Powered xxx", "Crazy xxx", "Lazy xxx", "Sudden xxx",
      "Path to xxx", "Fall-under xxx", "Time of xxx", "xxx Lick", "xxx Action",
      "Suckle xxx", "Play with xxx", "Demonic xxx", "Underworld xxx",
      "Vamparic xxx", "Seductive xxx", "Christmas xxx", "Awkward xxx",
      "Siphon xxx", "Reduce to xxx", "Touched by xxx", "Empowered by xxx"
    ]

    POSSIBLE_EFFECTS = [:power,:power,:power,:power,:power,:state,:abi_change,:rev_damage,:rev_state]

    def self.create_random
      level = rand(1..5)
      scope = [:enemy,:enemy,:enemy,:enemy,:self].sample
      seed = []
      power = 0
      abi_change = Hash.new(0)
      rev_change = Hash.new(0)
      state_pull = scope == :enemy ? O_STATES : D_STATES
      state_rev_pull = scope != :enemy ? O_STATES : D_STATES
      states = []
      level.times do
        if scope == :self
          seed << POSSIBLE_EFFECTS.drop(4).sample
        else
          seed << POSSIBLE_EFFECTS.sample
        end
      end
      cost = 4
      seed.each do |type|
        case type
        when :power
          power += 15 if power == 0
          power += 8 + rand(4)
        when :state
          states << State.new(*state_pull.sample)
          cost += 1
        when :abi_change
          abi_change[STATS.sample] += 4 + rand(4)
          cost += 1
        when :rev_damage
          power += 15 if power == 0
          rev_change[STATS.sample] += 8 + rand(4)
          power += 15 + rand(8)
        when :rev_state
          power += 15 if power == 0
          states << State.new(*state_rev_pull.sample)
          power += 15 + rand(8)
        end
      end

      name = NAMES.sample.gsub("xxx",ELEMENTS.sample.to_s.capitalize)
      cost = 4
      level.times { cost += rand(4..6) }
      if scope == :enemy
        Spell.new(name,power,cost,{ability_damage: abi_change,
          ability_boost: rev_change, states: states, scope: scope})
      else
        Spell.new(name,-power,cost,{ability_boost: abi_change,
          ability_damage: rev_change, states: states, scope: scope})
      end
    end


    attr_accessor :user
    attr_reader :name

    def initialize(name, power, cost, options = {})
      @user = nil
      @name = name
      @base_power = power
      @base_cost = cost
      default = {
        ability_damage: {},
        ability_boost: {},
        states: [],
        scope: :enemy
      }
      @options = default.merge(options)
    end

    def power
      @base_power * (@user.magic + 50) / 50
    end

    def cost
      Integer( @base_cost * (1.0 - @user.magic / (@user.magic + 100)) )
    end

    def scope
      @options[:scope]
    end

    def ability_damage
      @options[:ability_damage]
    end

    def ability_boost
      @options[:ability_boost]
    end

    def states
      @options[:states]
    end

    def can_use?
      @user.mp >= self.cost
    end

    def to_s
      length = @user.spells.max_by { |spell| spell.name.length }.name.length
      color = can_use? ? :light_green : :red
      str = "#{self.name}".ljust(length).colorize(color)
      str +="[#{self.cost} MP]: ".rjust(9).blue
      str += "#{scope.to_s.capitalize}:".ljust(7).magenta
      if power > 0
        str += "[Deal #{power} DMG] ".ljust(15).red
      elsif power < 0
        str += "[Heal #{-power} HP] ".ljust(15).green
      else
        str += "".ljust(15)
      end

      ability_damage.each do |stat, val|
        str += "[-#{val} #{stat.upcase}]".ljust(11).light_red
      end

      ability_boost.each do |stat, val|
        str += "[+#{val} #{stat.upcase}]".ljust(11).light_green
      end

      states.each do |state|
        str += "[+#{state.name}] ".ljust(10).yellow
      end

      str
    end

    def cast(target)
      target.apply_damage(power)

      states.each do |state|
        target.actor.apply_state(state.dup)
      end

      ability_damage.each do |stat, damage|
        target.actor.abi_damage[stat] += damage
      end

      ability_boost.each do |stat, boost|
        target.actor.abi_boost[stat] += boost
      end

      @user.mp -= cost
    end

  end

end
