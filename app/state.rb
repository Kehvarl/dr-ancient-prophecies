module Main

  def state_menu args
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
        args.state.game_state = :new_game
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

  def state_setup args
    args.state.output = []
    args.state.guess = nil
    args.state.current_stack = 0
    args.state.stacks_top = []
    args.state.correct = 0
    args.state.incorrect = 0
    args.state.major = 0
    # args.state.major_incorrect = 0  # We never forget...
    args.state.deck.shuffle()
    args.state.game_state = :draw_first_card
  end

  def state_draw_first args
    args.state.game.tick(args)

    if args.state.deck.can_draw?
      position = args.state.game.positions[args.state.current_stack]
      card = args.state.deck.draw()
      args.state.output << card.render_sprite(position)
      args.state.stacks_top[args.state.current_stack] = card
      args.state.game_state = :player_input
    else
      puts args.state.stacks_top
      # Nothing to draw
      # Options: Reshuffle, magically summon more cards, or end round.
    end

  end

  def state_get_guess args
    clicked = args.state.game.tick(args)
    if clicked
      # puts clicked
      args.state.guess = clicked
      args.state.game_state = :draw_next_card
    end

    render_game(args)
  end

  def state_draw_card args
    args.state.game.tick(args)

    if args.state.deck.can_draw?
      position = args.state.game.positions[args.state.current_stack]
      card = args.state.deck.draw()
      args.state.output << card.render_sprite(position)
      args.state.stacks_top[args.state.current_stack] = card
      args.state.game_state = :check_guess
    else
      puts args.state.stacks_top
      # Nothing to draw
      # Options: Reshuffle, magically summon more cards, or end round.
    end

    if args.state.deck.last and args.state.deck.current and (args.state.deck.last == args.state.deck.current)
      # duplicate value, draw again.
      # We might want to make this a special state with a message or animation.
      args.state.game_state = :draw_next_card
    end

  end

  def state_check_guess args
    #puts "#{args.state.guess}, #{args.state.deck.last}, #{args.state.deck.current}"

    # Extremely messy, and is checking, updating scores, updating stacks, and computing game over.

    # Do we have 2 cards?  If not, we need 2
    args.state.game_state = :player_input
    if not args.state.deck.last and args.state.deck.current
      args.state.game_state = :draw_next_card
      return
    end

    # Do we have a guess?  If not, we need a guess
    if not args.state.guess
      args.state.game_state = :player_input
      return
    end

    # Are the 2 cards equal?  If so, we should draw a new card
    if args.state.deck.current.value == args.state.deck.last.value
      args.state.game_state_delay = 30
      args.state.game_state = :handle_equal
      return
    end

    # If we have 2 cards of differing values and a guess
    # If the guess is correct:  Score up
    if args.state.guess == :lower and (args.state.deck.current.value < args.state.deck.last.value)
      args.state.correct += 1
    elsif args.state.guess == :higher and (args.state.deck.current.value > args.state.deck.last.value)
      args.state.correct += 1

    # If the guess if wrong:
    #   Record failure
    #   If the top card is major arcana, record major fail
    #   Trigger next-stack selection and first draw
    elsif args.state.guess == :lower and (args.state.deck.current.value > args.state.deck.last.value)
      args.state.game_state = :next_stack
      args.state.incorrect += 1
      if args.state.deck.last.major
        args.state.major_incorrect += 1
      end
    elsif args.state.guess == :higher and (args.state.deck.current.value < args.state.deck.last.value)
      args.state.game_state = :next_stack
      args.state.incorrect += 1
      if args.state.deck.last.major
        args.state.major_incorrect += 1
      end
    end
  end

  def state_handle_equal args
    # Maybe a nice "what we're doing message"
    # Actually, each state change could probably do this.

    args.state.game_state_delay -= 1
    if args.state.game_state_delay <= 0
      args.state.game_state = :draw_next_card
    end
  end

  def state_next_stack args
    # Select next stack
    args.state.current_stack += 1
    # If no stacks to select, game over
    # Do something to indicate the new stack
    # Trigger first-draw in new stack
    if args.state.current_stack >= 5
      args.state.game_state = :game_over
    else
      args.state.game_state = :draw_first_card
    end
  end

  def state_game_over args
  end
end
