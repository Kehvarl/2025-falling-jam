def init args
  args.state.blocks = []
end

def calc_physics args
  args.state.blocks.each do |b|
    b.y -= b.vy
    b.x += b.vx
    if b.x < 0 or b.x > 720
      b.x = b.x.clamp(0,720)
      b.vx = -b.vx
    end
  end
end

def add_block args
  args.state.blocks << {
    x: rand(18)*40, y: (rand(2) + 30)*40, w: 40, h: 40,
    path: "sprites/circle/blue.png",
    vy: 1, vx: 0
    }
end

def tick args
  if args.tick_count == 0
    init(args)
    add_block(args)
  end

  if args.inputs.keyboard.space or args.inputs.mouse.button_left
    add_block(args)
  end

  calc_physics(args)

  args.outputs.primitives << args.state.blocks


end

