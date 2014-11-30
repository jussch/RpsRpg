module RpsRpg

  class Item

    MATERIALS = {
      BRONZE: 80,
      IRON: 100,
      STEEL: 120,
      MYTHRIL: 140,
      ADAMANTIUM: 160
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

    def self.create_random(level = rand(1..5), type = ITEM_TYPES.keys.sample)
      material = MATERIALS.keys.sample
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
      @level * MATERIALS[@material]
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
      all_stats = [:maxhp, :maxmp, :atk, :arm, :stealth, :speed, :magic]
      all_stats.each { |stat| self.send("#{stat}=".to_sym,0) }

      stats = (5+rand(3)) * @level
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
          next if rand(2) == 0
          buff = [rand(stats), stats-used_stats].min

          used_stats += buff

          buff *= 3 if [:maxhp, :maxmp].include?(stat)
          buff *= MATERIALS[@material]
          buff /= 100

          self.send("#{stat}=".to_sym,self.send(stat) + buff)
        end
      end
    end

  end

end
