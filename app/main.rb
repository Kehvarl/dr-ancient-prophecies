require('app/cards.rb')
require('app/game.rb')
require('app/state.rb')

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
    when :check_guess
      state_check_guess(args)
    when :score
      state_score(args)
    when :next_stack
      state_next_stack(args)
    when :game_over
      state_game_over(args)      
    end
  end

  def draw_card_tick args
    args.state.game.tick(args)

    if args.state.deck.can_draw?
      position = args.state.game.positions[args.state.current_stack]
      card = args.state.deck.draw()
      args.state.output << card.render_sprite(position)
      args.state.stacks_top[args.state.current_stack] = card
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
      if args.state.guess == :lower and (args.state.deck.current.value < args.state.deck.last.value)
        @args.state.correct += 1
      elsif args.state.guess == :lower and (args.state.deck.current.value > args.state.deck.last.value)
        args.state.current_stack += 1
        @args.state.incorrect += 1
        if args.state.deck.last.major
          @args.state.major_incorrect += 1
        end
      elsif args.state.guess == :higher and (args.state.deck.current.value > args.state.deck.last.value)
        @args.state.correct += 1
      elsif args.state.guess == :higher and (args.state.deck.current.value < args.state.deck.last.value)
        args.state.current_stack += 1
        @args.state.incorrect += 1
        if args.state.deck.last.major
          @args.state.major_incorrect += 1
        end
      end

      puts "#{args.state.deck.current.value < args.state.deck.last.value}"

      if args.state.current_stack >= 5
        args.state.game_state = :game_over
      end

      if args.state.guess
        args.state.guess = nil
        args.state.game_state = :player_input
      elsif (args.state.deck.current.value == args.state.deck.last.value)
        # Oops, duplicate.  We need to draw again.
        # I suspectt we need to split calculating the result and drawing cards into separate states
      end
    end

    render_game(args)
  end

  def input_tick args
    clicked = args.state.game.tick(args)
    if clicked
      puts clicked
      args.state.guess = clicked
      args.state.game_state = :draw_card
    end

    render_game(args)
  end

  def render_game args
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

end
