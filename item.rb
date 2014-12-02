module RpsRpg

  class Item

    MATERIALS = {
      BRONZE: 60,
      IRON: 100,
      STEEL: 140,
      MYTHRIL: 180,
      ADAMANTIUM: 220
    }

    RARE_PREFIX = [
      "Powerful",
      "Scary",
      "Legendary",
      "Radiant",
      "Glowing",
      "Master Crafted"
    ]

    ITEM_TYPES = {
      :weapon => [
        "Long Sword",
        "Hand Axe",
        "Greatsword",
        "Halberd",
        "Flail",
        "Staff"
      ],
      :body =>[
        "Breast Plate",
        "Full Plate",
        "Chainmail"
      ],
      :helmet => [
        "Nose Guard",
        "Pointed Helm",
        "Circlet"
      ]
    }

    ALL_STATS = [:maxhp, :maxmp, :atk, :arm, :stealth, :speed, :magic]

    def self.create_random(level = rand(1..8),type = ITEM_TYPES.keys.sample)
      material = MATERIALS.keys.take(level).sample
      Item.new(level, type, material)
    end

    attr_accessor :maxhp, :maxmp, :atk, :arm, :stealth, :speed, :magic

    attr_reader :level, :material, :type

    def initialize(level, type, material)
      @level = level
      @type = type
      @material = material
      @name = generate_name
      generate_stats
    end

    def gold_cost
      ( MATERIALS[@material] / 3 + rand(9) ) * @level ** 2
    end

    def generate_name
      string = ""
      if @level >= 5
        string += RARE_PREFIX.sample + " "
      end
      string += @material.to_s.capitalize + " "
      string += ITEM_TYPES[@type].sample
    end

    def generate_stats
      ALL_STATS.each { |stat| self.send("#{stat}=".to_sym,0) }

      stats = rand(4..7) * @level
      used_stats = 0

      case @type
      when :weapon
        self.atk += rand(@level) + MATERIALS[@material] / 10
      when :body
        self.arm += rand(@level) + MATERIALS[@material] / 10
      when :helmet
        self.arm += rand(@level) + MATERIALS[@material] / 20
      end

      until used_stats >= stats
        all_stats.shuffle.each do |stat|
          buff = [rand(stats), stats-used_stats].min

          used_stats += buff

          buff *= 3 if stat == :maxhp
          buff *= 2 if stat == :maxmp
          buff *= MATERIALS[@material]
          buff /= 100

          self.send("#{stat}=".to_sym,self.send(stat) + buff)
        end
      end
    end

    def to_s(adjust = @name.length + 1)
      string =  "#{@name}".ljust(adjust).yellow
      string += "[#{@level}] ".light_black
      ALL_STATS.each { |stat| string += "[+#{self.send(stat)} #{stat.upcase}]".ljust(13) }
      string
    end

  end

end
