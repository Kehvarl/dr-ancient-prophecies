module Main

  def state_menu args
    # Button locations
    new_box = {x:15, y:545, w:1250, h:45}
    quit_box = {x:15, y:445, w:1250, h:45}

    # Get Input
    hover_new = args.inputs.mouse.intersect_rect?(new_box)
    hover_quit = args.inputs.mouse.intersect_rect?(quit_box)

    # Update state/process
    args.state.game_state_delay -= 1
    if args.state.game_state_delay <= 0
      if args.inputs.mouse.click
        if hover_quit
          DR.request_quit
        elsif hover_new
          args.state.game_state = :new_game
        end
      end
    end

    # Draw menu
    out = []
    out << {x:0, y:0, w:1280, h:720, r: 0, g: 96, b:40}.solid!
    out << {x:5, y:5, w:1270, h:710, r:0, g:0, b:0}.border!

    out << button(new_box, "New Game", {r: 0, g: 128, b:40}, hover_new)
    out << button(quit_box, "Quit", {r: 128, g: 128, b:40}, hover_quit)

    tx, ty = center_text({x:100, y:640, w:1080, h:100}, "Ancient Prophecies", 24)
    c = {r:Numeric.rand(32...44), g:Numeric.rand(44...64), b:Numeric.rand(32...44)}
    out << {x:tx, y:ty, text:"Ancient Prophecies", size_enum:24, **c}.label!

    out << {x:564, y:144, w:140, h:256, path: 'sprites/polo.png', a:Numeric.rand(144...160)}.sprite!

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
    create_starfield args
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
      #puts args.state.stacks_top
      # Nothing to draw
      # Options: Reshuffle, magically summon more cards, or end round.
      # Honestly, I should put covered cards in the discard pile and then I can shuffle that.
      args.state.deck.shuffle_discards()
      position = args.state.game.positions[args.state.current_stack]
      card = args.state.deck.draw()
      args.state.output << card.render_sprite(position)
      args.state.stacks_top[args.state.current_stack] = card
      args.state.game_state = :player_input
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

      # Might be neat to show the newly draw card offset from the old one, then
      # slide them together.  Would require some more complicated state machine

      args.state.output << card.render_sprite(position)
      args.state.deck.discard(args.state.stacks_top[args.state.current_stack])
      args.state.stacks_top[args.state.current_stack] = card
      args.state.game_state = :check_guess
    else
      args.state.deck.shuffle_discards()
      position = args.state.game.positions[args.state.current_stack]
      card = args.state.deck.draw()
      args.state.output << card.render_sprite(position)
      args.state.stacks_top[args.state.current_stack] = card
      args.state.game_state = :player_input
    end

    if args.state.deck.last and args.state.deck.current and (args.state.deck.last == args.state.deck.current)
      # duplicate value, draw again.
      # We might want to make this a special state with a message or animation.
      args.state.game_state = :draw_next_card
    end

    render_game(args)
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

    render_game(args)
  end

  def state_handle_equal args
    # Maybe a nice "what we're doing message"
    # Actually, each state change could probably do this.

    args.state.game_state_delay -= 1
    if args.state.game_state_delay <= 0
      args.state.game_state = :draw_next_card
    end

    render_game(args)
  end

  def state_next_stack args
    position = args.state.game.positions[args.state.current_stack]
    puts args.state.deck.current
    puts args.state.deck.current.major
    if args.state.deck.current.major
      args.state.output << {**position, path: :inactive_major}.sprite!
    else
      args.state.output << {**position, path: :inactive}.sprite!
    end
    # Select next stack
    args.state.current_stack += 1
    # If no stacks to select, game over
    # Do something to indicate the new stack
    # Trigger first-draw in new stack
    if args.state.current_stack >= 5
      args.state.game_state_delay = 40
      args.state.game_state = :game_over
    else
      args.state.game_state = :draw_first_card
    end

    render_game(args)
  end

  def state_game_over args

    args.state.game_state_delay -= 1

    args.outputs.primitives << {x:0, y:0, w:1280, h:720, r: 0, g: 0, b:0}.solid!

    render_game(args, false)
    args.outputs.primitives << {x:100, y:100, w:1080, h:520, r:160, g:192, b:128, a:192}.solid!
    args.outputs.primitives << {x:100, y:100, w:1080, h:520, r:0, g:0, b:0}.border!
    tx, ty = center_text({x:100, y:520, w:1080, h:100}, "Game Over")
    args.outputs.primitives << {x:tx, y:ty, text:"Game Over", r:0, g:0, b:0}.label!
    tx, ty = center_text({x:100, y:498, w:1080, h:32}, "Score")
    args.outputs.primitives << {x:tx, y:ty, text:"Score", r:0, g:0, b:0}.label!
    tx, ty = center_text({x:100, y:466, w:1080, h:24}, "Correct: #{args.state.correct}")
    args.outputs.primitives << {x:tx, y:ty, text:"Correct: #{args.state.correct}", r:0, g:0, b:255}.label!
    tx, ty = center_text({x:100, y:442, w:1080, h:24}, "Incorrect: #{args.state.incorrect}")
    args.outputs.primitives << {x:tx, y:ty, text:"Incorrect: #{args.state.incorrect}", r:128, g:0, b:0}.label!

    if args.state.game_state_delay <= 0
      tx, ty = center_text({x:100, y:340, w:1080, h:24}, "Click for Menu")
      args.outputs.primitives << {x:tx, y:ty, text:"Click for Menu", r:0, g:0, b:0}.label!
      if args.inputs.mouse.click
        args.state.game_state_delay = 30
        args.state.game_state = :menu
      end
    end
  end
end
