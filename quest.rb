module RpsRpg

  class Quest

    NOUN = ["Dragon", "Giant", "Orge", "Village", "Goblin Army", "Treasure",
            "Nest", "Bees", "Giant Flower", "Princess", "King", "Sausage",
            "Peasant", "Milk", "Steak", "Thief", "Murderer", "Werewolf", "Mayo",
            "Little Girl", "Old Man", "Terrorist", "Vampire", "Teenager"]

    VERB = ["Kill", "Eat", "Hug", "Tickle", "Acquire", "Rescue", "Play with",
            "Nurture", "Find", "Free", "Beat Up", "Kiss", "Shank", "Rob",
            "Terrorize", "Destroy", "Arrest", "Fist", "Bully", "Ransack"]

    QUEST_TYPES = [:atk, :arm, :speed, :magic, :stealth]

    def self.generate_random
      level = rand(1..6)
      type = QUEST_TYPES.sample
      name = VERB.sample + " the " + NOUN.sample

      items = [Item.create_random(rand(level)+1)]

      rewards = {
        gold: ( 100 + rand(80..140) * level ),
        items: items.drop(rand(0..1)),
        levels: ( 1 + level / 3 )
      }
      Quest.new(level, type, rewards, name)
    end

    attr_reader :type, :level, :name

    def initialize(level, type, rewards, name)
      @level, @type, @rewards, @name = level, type, rewards, name
    end

    def optimal_score
      23 + 2 * @level ** 2
    end

    def gold_cost
      0 #filler
    end

    def risk
      30 + 5 * @level ** 2
    end

    def gold_gain
      @rewards[:gold]
    end

    def level_gain
      @rewards[:levels]
    end

    def item_drop
      @rewards[:items]
    end

    def to_s
      string =  "#{@name}".ljust(25).light_magenta
      string += "[Optimal #{@type.upcase}: #{optimal_score}]".ljust(20)
      string += "[Risk: #{risk} HP]".red
      string += "[Cost: #{risk/3} HP]".light_red
      string += "[+#{self.gold_gain} Gold]".light_yellow
      string += "[+#{self.level_gain} Levels]".light_yellow
      unless item_drop.empty?
        string += "[#{self.item_drop.first}]"
      end
      string
    end

    def do_quest(player)
      req_stat = player.send(@type)
      if rand(optimal_score) > req_stat
        player.actor.hp -= risk * 4 / 3
      else
        player.actor.hp -= risk / 3
      end
      player.gold += gold_gain
      level_gain.times { player.actor.level_up }
      player.acquire(item_drop.first) unless item_drop.empty?
    end

  end

end
