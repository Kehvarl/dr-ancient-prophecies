class Button
  def initialize vars
    @x = vars.x || 0
    @y = vars.y || 0
    @w = vars.w || 96
    @h = vars.h || 64
    @text = vars.text || "UNSET TEXT"
    @color = vars.color || {r:128, g:128, b:128}
    @color_hover = vars.color || {r:160, g:160, b:160}
    @color_click = vars.color || {r:192, g:192, b:192}
    @value = vars.value || nil
  end

  def draw hover:false, clicked:false
    out = []
    c= @color
    if clicked
      c = @color_click
    elsif hover
      c = @color_hover
    end
    out << {x:@x, y:@y, w:@w, h:@h, **c}.solid!
    out << {x:@x+18, y:@y+54, text:@text, r:0, g:0, b:0}.label!
    out << {x:@x, y:@y, w:@w, h:@h, r:0, g:0, b:0}.border!

    out
  end

  def tick args
    args.outputs.primitives << draw(hover:args.inputs.mouse.intersect_rect?(self), clicked:args.inputs.mouse.click)
    if args.inputs.mouse.intersect_rect?(self) and args.inputs.mouse.click
      return @value
    else
      return nil
    end
  end
end


class Game
  def initialize
  end

  def draw_playfield
  end

  def draw_buttons
  end

  def

  def tick args
  end
end
