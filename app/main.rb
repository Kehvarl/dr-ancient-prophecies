require('app/cards.rb')

module Main
  def initialize args
    args.state.deck = Deck.new()
    args.state.deck.unshuffle()
    args.state.x = 10
    args.state.output = []
  end
  def tick args
    if args.state.tick_count == 0
      initialize args
    end
    args.outputs.primitives << {x: 0, y: 0, w: 1280, h: 720,
                                r: 0, g: 80, b:40}.solid!
    args.outputs.primitives << {x: 640, y: 360, w: 640, h: 640,
                                path: 'sprites/circle/green.png'}.sprite!

    if args.state.deck.can_draw?
      args.state.output << args.state.deck.draw().render(args.state.x, 300, 128, 196)
      args.state.x += 22
    end
    args.outputs.primitives << args.state.output
  end
end
