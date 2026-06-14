class Button
  attr_accessor :x, :y, :w, :h, :text, :value
  def initialize vars
    @x = vars.x || 0
    @y = vars.y || 0
    @w = vars.w || 96
    @h = vars.h || 64
    @text = vars.text || "UNSET TEXT"
    @color = vars.color || {r:128, g:128, b:128}
    @color_hover = vars.color_hover || {r:160, g:160, b:160}
    @color_click = vars.color_click || {r:192, g:192, b:192}
    @value = vars.value || nil
  end

  def draw hover:false, clicked:false
    out = []
    c= @color
    if clicked and hover
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
  attr_accessor :positions
  def initialize
    @lower = Button.new({x:918, y:64, w:96, h:96, text:"Lower", value: :lower,
                        color: {r:128, g:164, b:128},
                        color_hover: {r:128, g:196, b:128},
                        color_click: {r:128, g:255, b:128}})
    @higher = Button.new({x:1026, y:64, w:96, h:96, text:"Higher", value: :higher,
                        color: {r:164, g:128, b:128},
                        color_hover: {r:196, g:128, b:128},
                        color_click: {r:255, g:128, b:128}})

    @positions = [
      {x:474, y:510, w:132, h:200, angle:0},
      {x:474, y:300, w:132, h:200, angle:0},
      {x:474, y:90, w:132, h:200, angle:0},
      {x:664, y:470, w:132, h:200, angle:315},
      {x:282, y:260, w:132, h:200, angle:45},
    ]
  end

  def placeholder args
    args.outputs[:placeholder].w = 132
    args.outputs[:placeholder].h = 200
    args.outputs[:placeholder].primitives << {x:0, y:0, w:132, h:200, r:64, g:16, b:16}.solid!
    args.outputs[:placeholder].primitives << {x:0, y:0, w:132, h:200, r:0, g:0, b:0}.border!
  end

  def draw_playfield args
    out = []
    out << {x: 0, y: 0, w: 1280, h: 720, r: 0, g: 80, b:40, a:(255 -  (args.state.incorrect * 64))}.solid!
    out << {x:958, y:498, w:132, h:200, r:0, g:0, b:0}.border!

    @positions.each do |p|
      out << {x:p.x, y:p.y, w:p.w, h:p.h, angle:p.angle, path: :placeholder}.sprite!
    end

    out
  end

  def draw_buttons
    [{x:918, y:170, w:204, h:64, r:128, g:128, b:128}.solid!,
     {x:928, y:213, text:"Next Card Will Be:", r:0, g:0, b:0}.label!,
     {x:919, y:170, w:204, h:64, r:0, g:0, b:0}.border!]
  end

  def tick args
    args.outputs.primitives << draw_playfield(args)
    args.outputs.primitives << draw_buttons()
    l = @lower.tick(args)
    h = @higher.tick(args)
    if l
      return :lower
    elsif h
      return :higher
    else
      return false
    end
  end
end
