module Main
  class Card
    attr_accessor :render_target_offset
    def initialize vars={}
      suit = vars.suit || ["", nil]

      @suit = suit[0] || ""
      @suit_offset = suit[1]
      @render_target_offset = vars.render_target_offset || 0
      @color = vars.color || {r:0, g:0, b:0}
      @value = vars.value || 0
      @symbol = vars.symbol || ""
      @face = vars.face || false
      @major = vars.major || false
      @name = vars.name || "No Card"
    end

    def render x, y, w=64, h=96
      out = []
      out << {x:x, y:y, w:w, h:h, r:148, g:132, b:164}.solid!
      out << {x:x, y:y, w:w, h:h, r:0, g:0, b:0}.border!
      out << {x:x+4, y:y+24, text:@symbol, **@color}.label!
      out << {x:(x+w-24), y:(y+h-8), text:@symbol, **@color}.label!
      if @suit_offset
        out << {x:(x+w-24), y:y+8, h:16, w:16, tile_w:16, tile_x:@suit_offset, path:"sprites/suites.png"}.sprite!
        out << {x:x+4, y:(y+h-24), h:16, w:16, tile_w:16, tile_x:@suit_offset, path:"sprites/suites.png"}.sprite!
      else
        out << {x:(x+w-24), y:y+24, text:@suit.to_s, **@color}.label!
        out << {x:x+4, y:(y+h-8), text:@suit.to_s, **@color}.label!
      end
      if not @major
        nw, nh = DR.calcstringbox(@name.to_s)
        out << {x:x+(w.div(2) - (nw.div(2))), y:(y+(h.div(2))), text:@name, **@color}.label!
      else
        nw, nh = DR.calcstringbox(@name.to_s)
        lines = String.wrapped_lines(@name.to_s, 11)
        line_y = 12 + (nh * lines.length())
        lines.each do |line|
          nw, nh = DR.calcstringbox(line)
          out << {x:x+(w.div(2) - (nw.div(2))), y:line_y, text:line, **@color}.label!
          line_y -= nh
        end
      end
      out
    end

    def render_sprite position, w:128, h:196
      position.merge({path: :cards,
                      source_x: @render_target_offset,
                      source_w: w, source_h: h}).sprite!
    end
  end

  class Deck
    def initialize
      primary=[
        [1,"A", "Ace"],[2,2,2],[3,3,3],[4,4,4],[5,5,5],[6,6,6],
        [7,7,7],[8,8,8],[9,9,9],[10,10,10],
        [11,"J","Jack"],[12,"Q","Queen"],[13,"K","King"]]
      major = [
        [0,"","The Open Path"],[1,"","The Fire Beneath"],[2,"","The Veiled One"],
        [3,"","The Blooming Dark"],[4,"","The Black Throne"],[5,"","The Keeper of Rites"],
        [6,"","The Binding"],[7,"","The Procession"],[8,"","The Bound Beast"],
        [9,"","The Candle In Dust"],[10,"","The Wheel of Stars"],[11,"","The Hidden Balance"],
        [12,"","The Watcher Below"],[13,"","The Waiting Tomb"],[14,"","The Black Vessel"],
        [15,"","The Opened Door"],[16,"","The Broken Rings"],[17,"","The Silver Gate"],
        [18,"","The Hollow Moon"],[19,"","The Dying Sun"],[20,"","The Sleeper Stirs"],
        [21,"","The Outer Gates"],
      ]
      colors=[{r:80, g:0, b:0}, {r:0, g:0, b:80}]
      color = 0
      rto = 0
      @cards = []
      [["C",32],["K",16],["A",48],["S",0]].each do |suit|
        c = colors[color]
        primary.each do |value|
          face = (value[0] > 10)
          @cards << Card.new({suit:suit, value:value[0], symbol:value[1], name:value[2],
                              face:face, color:c, render_target_offset:rto})
          rto += 128
        end
        color = (color +1) %2
      end
      major.each do |value|
        @cards << Card.new({suit:"", value:value[0], symbol:value[1], name:value[2],
                            face:false, major:true, color:{r:0, g:0, b:0},
                            render_target_offset:rto})
        rto += 128
      end
      @deck = []
      @discards = []
    end

    def create_card_render_target args
      unshuffle()
      deck = fan()

      render = []
      deck.each do |card|
        render << card.render(card.render_target_offset, 0, 128, 196)
      end
      args.outputs[:cards].w = 128*deck.length()
      args.outputs[:cards].h = 196
      args.outputs[:cards] << render

    end

    def unshuffle
      @deck = @cards.clone()
      @discards = []
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
      if @cards.include?(card)
        @discards << card
      end
    end

    def fan
      @deck.dup
    end

    def discards
      @discards
    end

    def render x, y, w=64, h=96
      out = []
      if can_draw?()
        out << {x:x, y:y, w:w, h:h, r:148, g:132, b:164}.solid!
        out << {x:x, y:y, w:w, h:h, r:0, g:0, b:0}.border!
        nw, nh = DR.calcstringbox("Ancient")
        out << {x:x+(w.div(2) - (nw.div(2))), y:(y+(h.div(2))+nh), text:"Ancient", r:80, g:0, b:80}.label!
        nw, nh = DR.calcstringbox("Prophecies")
        out << {x:x+(w.div(2) - (nw.div(2))), y:(y+(h.div(2))), text:"Prophecies", r:80, g:0, b:80}.label!
      else
        out << {x:x, y:y, w:w, h:h, r:0, g:80, b:0}.solid!
        out << {x:x, y:y, w:w, h:h, r:0, g:0, b:0}.border!
      end
      out
    end
  end
end
