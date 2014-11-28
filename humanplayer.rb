module RpsRpg

  class HumanPlayer

    attr_accessor :actor
    attr_reader :name

    def initialize(name = 'Billy Bob')
      @actor = nil
      @name = name
    end

    def get_jobclass(selection)
      puts "#{@name}, choose a class:"

      full_render = Array.new
      selection.size.times do |i|
        render = selection[i].render
        render[0] = "[#{i}] " + render[0]
        (0...render.size).to_a.each do |j|
          if full_render[j].nil?
            full_render[j] = render[j]
          else
            full_render[j] += "\t" + render[j]
          end
        end
      end
      puts full_render.join("\n")
      
      input = Integer(gets.chomp)
      selection[input]
    end

    def lost?
      @actor.hp <= 0
    end

  end

end
