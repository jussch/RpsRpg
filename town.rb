module RpsRpg

  class Town

    attr_reader :shop, :witch, :quests, :name

    SHOP_SIZE = 8
    WITCH_SIZE = 8
    QUEST_SIZE = 8

    def initialize(shop_size = SHOP_SIZE, witch_size = WITCH_SIZE, quest_size = QUEST_SIZE)
      @shop = setup_shop(shop_size)
      @witch = setup_witch(witch_size)
      @quests = setup_quests(quest_size)
      @name = generate_name
    end

    def setup_shop(size)
      arr = []
      size.times do
        arr << Item.create_random
      end
      arr
    end

    def setup_witch(size)
      arr = []
      size.times do
        arr << Spell.create_random
      end
      arr
    end

    def setup_quests(size)
      arr = []
      size.times do
        arr << Quest.generate_random
      end
      arr
    end

    def generate_name
      "New York"
    end

  end

end
