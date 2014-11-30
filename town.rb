module RpsRpg

  class Town

    attr_reader :shop, :quests, :name

    def initialize(shop_size)
      @shop = setup_shop(shop_size)
      @quests = setup_quests
      @name = generate_name
    end

    def setup_shop(shop_size)
      hash = []
      shop_size.times do
        new_item = Item.create_random
        hash[new_item] = new_item.gold_cost
      end
      hash
    end

    def setup_quests
    end

    def generate_name
    end

  end

end
