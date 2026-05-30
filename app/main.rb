require('app/cards.rb')

module Main
  def initialize args
    args.state.game_state = :menu
    args.state.deck = Deck.new()
    args.state.x = 10
    args.state.output = []
    args.state.current_stack = 0
    args.state.correct = 0
    args.state.incorrect = 0
    args.state.major = 0
    args.state.major_incorrect = 0
    args.state.deck.create_card_render_target(args)
        args.state.deck.shuffle()
  end

  def tick args
    if args.state.tick_count == 0
      initialize args
    end
    case args.state.game_state
    when :menu
      args.state.game_state = :draw_card
    when :draw_card
      draw_card_tick args
    when :player_input
      #input_tick args
      args.state.game_state = :draw_card
    end
  end

  def draw_card_tick args
    args.outputs.primitives << draw_playfield(args)

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
    elsif args.inputs.mouse.click or args.inputs.keyboard.key_up.space
      args.state.deck.shuffle()
      args.state.output = []
    end
    args.outputs.primitives << args.state.output
    args.outputs.primitives << args.state.deck.render(960, 500, 128, 196)
  end

  def input_next_tick args
    args.outputs.primitives << draw_playfield(args)
    args.outputs.primitives << args.state.output
    args.outputs.primitives << draw_player_buttons(args)

    out = nil
    if args.mouse.click
      if args.mouse.intersect_rect?({x:918, y:64, w:96, h:96})
        out = :lower
      end

      if args.mouse.intersect_rect?({x:1026, y:64, w:96, h:96})
        out = :higher
      end
    end
    out
  end

  def draw_playfield args
    out = []
    out << {x: 0, y: 0, w: 1280, h: 720, r: 0, g: 80, b:40}.solid!
    out << {x:958, y:498, w:132, h:200, r:0, g:0, b:0}.border!

    out << {x:474, y:510, w:132, h:200, path:"sprites/square/black.png"}.sprite!
    out << {x:474, y:300, w:132, h:200, path:"sprites/square/black.png"}.sprite!
    out << {x:474, y:90, w:132, h:200, path:"sprites/square/black.png"}.sprite!

    out << {x:664, y:470, w:132, h:200, angle:315, path:"sprites/square/black.png"}.sprite!
    out << {x:282, y:260, w:132, h:200, angle:45, path:"sprites/square/black.png"}.sprite!

    out << {x:918, y:170, w:204, h:64, r:128, g:128, b:128}.solid!
    out << {x:928, y:213, text:"Next Card Will Be:", r:0, g:0, b:0}.label!
    out << {x:919, y:170, w:204, h:64, r:0, g:0, b:0}.border!

    out << {x:918, y:64, w:96, h:96, r:128, g:164, b:128}.solid!
    out << {x:936, y:120, text:"Lower", r:0, g:0, b:0}.label!
    out << {x:918, y:64, w:96, h:96, r:0, g:0, b:0}.border!

    out << {x:1026, y:64, w:96, h:96, r:164, g:128, b:128}.solid!
    out << {x:1046, y:120, text:"Higher", r:0, g:0, b:0}.label!
    out << {x:1026, y:64, w:96, h:96, r:0, g:0, b:0}.border!

    out
  end

  def draw_player_buttons args
    out = []
    c= {r:128, g:196, b:128}
    if args.mouse.intersect_rect?({x:918, y:64, w:96, h:96})
      c = {r:128, g:255, b:128}
    end
    out << {x:918, y:64, w:96, h:96, **c}.solid!
    out << {x:936, y:120, text:"Lower", r:0, g:0, b:0}.label!
    out << {x:918, y:64, w:96, h:96, r:0, g:0, b:0}.border!

    c= {r:196, g:128, b:128}
    if args.mouse.intersect_rect?({x:1026, y:64, w:96, h:96})
      c = {r:255, g:128, b:128}
    end
    out << {x:1026, y:64, w:96, h:96, **c}.solid!
    out << {x:1046, y:120, text:"Higher", r:0, g:0, b:0}.label!
    out << {x:1026, y:64, w:96, h:96, r:0, g:0, b:0}.border!

    out
  end
end
