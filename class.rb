module RpsRpg

  class Class

    BASE_ABI = {
      maxhp: 300
      maxmp: 100
      atk: 24
      armor: 24
      stealth: 24
      speed: 24
      magic: 24
    }

    BASE_ABI_GROWTH = {
      maxhp: 30
      maxmp: 10
      atk: 6
      armor: 6
      stealth: 4
      speed: 4
      magic: 6
    }

    ABI_MODIFIERS = {
      # -- Percentile Values ( 100 = normal )
      primary: 150
      secondary: 140
      tertiary: 125
      weakness: 80
      weakness2: 70
    }

    def initialize(modifiers)
      @base = BASE_ABI.dup
      @growth = BASE_ABI_GROWTH.dup
      modifiers.each do |ord, ability|
        @base[ability] *= ABI_MODIFIERS[ord]
        @base[ability] /= 100
        @growth[ability] *= ABI_MODIFIERS[ord]
        @growth[ability] /= 100
      end
    end

  end

end