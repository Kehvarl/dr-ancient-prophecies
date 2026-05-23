module Main
  def tick args
    args.outputs.primitives << { x: 640, y: 360, w: 640, h: 640,
                              anchor_x: 0.5,
                              anchor_y: 0.5,
                              path: 'sprites/circle/green.png'}.sprite!
  end
end
