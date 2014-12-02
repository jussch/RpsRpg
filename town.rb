module RpsRpg

  class Town

    attr_reader :shop, :witch, :quests, :name

    SHOP_SIZE = 5
    WITCH_SIZE = 5
    QUEST_SIZE = 5

    def initialize
      @shop = setup_shop
      @witch = setup_witch
      @quests = setup_quests
      @name = generate_name
    end

    def setup_shop
      hash = {}
      SHOP_SIZE.times do
        new_item = Item.create_random
        hash[new_item] = new_item.gold_cost
      end
      hash
    end

    def setup_witch
      hash = {}
      WITCH_SIZE.times do
        new_spell = Spell.create_random
        hash[new_item] = new_spell.gold_cost
      end
      hash
    end

    def setup_quests
      arr = []
      QUEST_SIZE.times do
        arr << Quest.create_random
      end
      arr
    end

    def generate_name
      "New York"
    end

  end

end
