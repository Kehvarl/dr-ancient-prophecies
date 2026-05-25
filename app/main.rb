require('app/cards.rb')

module Main
  def initialize args
    args.state.deck = Deck.new()
    args.state.x = 10
    args.state.output = []
    args.state.deck.create_card_render_target(args)
        args.state.deck.shuffle()
  end

  def draw_playfield
    out = []
    out << {x: 0, y: 0, w: 1280, h: 720, r: 0, g: 80, b:40}.solid!
    out << {x:958, y:498, w:132, h:200, r:0, g:0, b:0}.border!

    out << {x:474, y:510, w:132, h:200, path:"sprites/square/black.png"}.sprite!
    out << {x:474, y:300, w:132, h:200, path:"sprites/square/black.png"}.sprite!
    out << {x:474, y:90, w:132, h:200, path:"sprites/square/black.png"}.sprite!

    out << {x:664, y:470, w:132, h:200, angle:315, path:"sprites/square/black.png"}.sprite!
    out << {x:282, y:260, w:132, h:200, angle:45, path:"sprites/square/black.png"}.sprite!

  end

  def tick args
    if args.state.tick_count == 0
      initialize args
    end
    args.outputs.primitives << draw_playfield

    positions = [
      {x:474, y:510, w:132, h:200},
      {x:474, y:300, w:132, h:200},
      {x:474, y:90, w:132, h:200},
      {x:664, y:470, w:132, h:200, angle:315},
      {x:282, y:260, w:132, h:200, angle:45},
    ]

    if args.state.deck.can_draw?
      card = args.state.deck.draw()
      args.state.output << card.render_sprite(positions.sample())
    end
    args.outputs.primitives << args.state.output
    args.outputs.primitives << args.state.deck.render(960, 500, 128, 196)
  end
end
