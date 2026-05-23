module Main
  class Card
    def initialize vars={}
      @suit = vars.suit || ""
      @color = vars.color || {r:0, g:0, b:0}
      @value = vars.value || 0
      @face = vars.face || false
      @name = vars.name || "No Card"
    end

    def render x, y, w=64, h=96
      out = []
      out << {x:x, y:y, w:w, h:h, r:148, g:132, b:164}.solid!
      out << {x:x, y:y, w:w, h:h, r:0, g:0, b:0}.border!
      out << {x:x+4, y:y+24, text:@value.to_s, **@color}.label!
      out << {x:(x+w-24), y:(y+h-8), text:@value.to_s, **@color}.label!
      out << {x:x+16, y:(y+(h/2)), text:@name, **@color}.label!
      out
    end
  end

  class Deck
    def initialize
      names=["Ace",2,3,4,5,6,7,8,9,10,"Jack","Queen","King"]
      colors=[{r:80, g:0, b:0}, {r:0, g:0, b:80}]
      color = 0
      @cards = []
      ["C","K","A","S"].each do |suit|
        c = colors[color]
        [1,2,3,4,5,6,7,8,9,10,11,12,13].each do |value|
          name = names[value-1]
          face = (value > 10)
          @cards << Card.new({suit:suit, value:value, name:name, face:face, color:c})
        end
        color = (color +1) %2
      end
      @deck = []
      @discards = []
    end

    def unshuffle
      @deck = @cards.clone()
      @discardsdis = []
    end

    def shuffle
      @deck = @cards.shuffle()
      @discards = []
    end

    def can_draw?
      @deck.length > 0
    end

    def draw
      @deck.pop()
    end

    def discard card
      if @cards.contains?(card)
        @discards << card
      end
    end

    def fan
      @deck
    end

    def discards
      @discards
    end
  end
end
