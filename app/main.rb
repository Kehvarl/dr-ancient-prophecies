require('app/cards.rb')
require('app/game.rb')
require('app/state.rb')

module Main
  def initialize args
    args.state.game_state = :menu
    args.state.game_state_delay = 30
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

    args.outputs[:active].w = 132
    args.outputs[:active].h = 200
    args.outputs[:active].primitives << {x:0, y:0, w:132, h:200, r:255, g:255, b:255}.border!

    args.outputs[:inactive].w = 132
    args.outputs[:inactive].h = 200
    args.outputs[:inactive].primitives << {x:0, y:0, w:132, h:200, r:255, g:255, b:255, a:128}.solid!

    args.outputs[:inactive_major].w = 132
    args.outputs[:inactive_major].h = 200
    args.outputs[:inactive_major].primitives << {x:0, y:0, w:132, h:200, r:255, g:255, b:255, a:128}.solid!
    args.outputs[:inactive_major].primitives << {x:0, y:0, w:132, h:200, path:'sprites/polo.png', a:96}.sprite!
  end

  def tick args
    if args.state.tick_count == 0
      initialize args
    end
    case args.state.game_state
    when :menu
      state_menu(args)
    when :new_game
      state_setup(args)
    when :draw_first_card
      state_draw_first(args)
    when :player_input
      state_get_guess(args)
    when :draw_next_card
      state_draw_card(args)
    when :handle_equal
      state_handle_equal(args)
    when :check_guess
      state_check_guess(args)
    when :next_stack
      state_next_stack(args)
    when :game_over
      state_game_over(args)
    end

  end

  def render_game args, bg=true
    args.state.angle ||= 0
    args.state.angle += 0.01
    args.outputs.primitives << {x:640, y:360, w:1600, h:1600,
                                angle: args.state.angle,
                                anchor_x:0.5, anchor_y:0.5, path: :starfield}
    if bg
      args.outputs.primitives << args.state.game.tick(args)
    end
    args.outputs.primitives << args.state.output
    args.outputs.primitives << args.state.deck.render(960, 500, 128, 196)
    if args.state.current_stack < 5
      position = args.state.game.positions[args.state.current_stack]
      args.state.output << {**position, path: :active}.sprite!
    end
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

  def center_text box, text, size=1
    tw, th = DR.calcstringbox(text, size_enum:size)
    tx = (box.x + box.w.div(2)) - (tw.div(2))
    ty = (box.y + box.h.div(2)) #- (th.div(2))
    return tx, ty
  end

  def create_starfield args
    args.outputs[:starfield].w = 1600
    args.outputs[:starfield].h = 1600
    2500.times do
      x = Numeric.rand(0...1600)
      y = Numeric.rand(0...1600)
      c = {r:Numeric.rand(0...255), g:Numeric.rand(128...255), b:Numeric.rand(128...255)}
      s = Numeric.rand(1..4)
      args.outputs[:starfield].primitives << {x:x, y: y, w: s, h: s, **c}.solid!
    end
  end

end
