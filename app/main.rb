require('app/cards.rb')
require('app/game.rb')

module Main
  def initialize args
    args.state.game_state = :menu
    args.state.deck = Deck.new()
    args.state.game = Game.new()
    args.state.game.placeholder(args)
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
      menu_tick args
    when :draw_card
      draw_card_tick args
    when :player_input
      #input_tick args
      args.state.game_state = :draw_card
    end
  end

  def draw_card_tick args
    args.state.game.tick(args)

    if args.state.deck.can_draw?
      card = args.state.deck.draw()
      args.state.output << card.render_sprite(args.state.game.positions.sample())
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

  def button box, text, color, mouse
    tw, th = DR.calcstringbox(text)
    tx = 640 - (tw.div(2))
    ty = box.y + box.h - (th.div(2))
    if mouse.intersect_rect?(box)
      color.r += 32
      color.g += 32
      color.b += 32
    end
    out = []
    out << {**box, **color}.solid!
    out << {x:tx, y:ty, text:text, r:0, g:0, b:0}.label!
    out << {**box, r:0, g:0, b:0}.border!
    out
  end

  def menu_tick args
    # Get Input
    # Update state/process
    # Draw menu
    out = []
    out << {x:0, y:0, w:1280, h:720, r: 0, g: 96, b:40}.solid!
    out << {x:5, y:5, w:1270, h:710, r:0, g:0, b:0}.border!

    out << button({x:15, y:445, w:1250, h:45}, "New Game", {r: 0, g: 128, b:40}, args.inputs.mouse)
    out << button({x:15, y:295, w:1250, h:45}, "Quit", {r: 128, g: 128, b:40}, args.inputs.mouse)

    args.outputs.primitives << out
  end

end
