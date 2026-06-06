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
    args.state.guess = nil
    args.state.current_stack = 0
    args.state.stacks_top = []
    args.state.correct = 0
    args.state.incorrect = 0
    args.state.major = 0
    args.state.major_incorrect = 0
    args.state.deck.create_card_render_target(args)
    args.state.deck.shuffle()
  end

  def start_new args
    args.state.output = []
    args.state.guess = nil
    args.state.current_stack = 0
    args.state.stacks_top = []
    args.state.correct = 0
    args.state.incorrect = 0
    args.state.major = 0
    # args.state.major_incorrect = 0  # We never forget....
    args.state.deck.shuffle()
    args.state.game_state = :draw_card
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
      input_tick args
    end
  end

  def draw_card_tick args
    args.state.game.tick(args)

    if args.state.deck.can_draw?
      pid = Numeric.rand(args.state.game.positions.length)
      position = args.state.game.positions[pid]
      card = args.state.deck.draw()
      args.state.output << card.render_sprite(position)
      args.state.stacks_top[pid] = card
    #elsif args.inputs.mouse.click or args.inputs.keyboard.key_up.space
    #  args.state.deck.shuffle()
    #  args.state.output = []
    else
      puts args.state.stacks_top
      # Nothing to draw
      # Options: Reshuffle, magically summon more cards, or end round.
    end

    puts "#{args.state.guess}, #{args.state.deck.last}, #{args.state.deck.current}"
    if args.state.deck.last and args.state.deck.current
      puts "#{args.state.deck.current.value < args.state.deck.last.value}"
    end

    args.state.guess = nil
    args.state.game_state = :player_input
    args.outputs.primitives << args.state.output
    args.outputs.primitives << args.state.deck.render(960, 500, 128, 196)
  end

  def input_tick args
    clicked = args.state.game.tick(args)
    if clicked
      puts clicked
      args.state.guess = clicked
      args.state.game_state = :draw_card
    end

    args.outputs.primitives << args.state.output
    args.outputs.primitives << args.state.deck.render(960, 500, 128, 196)
  end

  def button box, text, color, hover
    tw, th = DR.calcstringbox(text)
    tx = 640 - (tw.div(2))
    ty = box.y + box.h - (th.div(2))
    if hover
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
    # Button locations
    new_box = {x:15, y:445, w:1250, h:45}
    quit_box = {x:15, y:295, w:1250, h:45}

    # Get Input
    hover_new = args.inputs.mouse.intersect_rect?(new_box)
    hover_quit = args.inputs.mouse.intersect_rect?(quit_box)

    # Update state/process
    if args.inputs.mouse.click
      if hover_quit
        DR.request_quit
      elsif hover_new
        start_new(args)
      end
    end

    # Draw menu
    out = []
    out << {x:0, y:0, w:1280, h:720, r: 0, g: 96, b:40}.solid!
    out << {x:5, y:5, w:1270, h:710, r:0, g:0, b:0}.border!

    out << button(new_box, "New Game", {r: 0, g: 128, b:40}, hover_new)
    out << button(quit_box, "Quit", {r: 128, g: 128, b:40}, hover_quit)

    args.outputs.primitives << out
  end

end
