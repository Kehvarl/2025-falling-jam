def init args
  args.state.falling = []
  args.state.landed = []
  args.state.heights = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
end

def calc_physics args
  args.state.falling.each do |b|
    b.y -= b.vy
    b.x += b.vx
    if b.x < 0 or b.x > 720
      b.x = b.x.clamp(0,720)
      b.vx = -b.vx
    end
    if b.y <= args.state.heights[b.x/40]
      b.y = args.state.heights[b.x/40].clone
      b.vy = 0
      b.vx = 0
      args.state.heights[b.x/40] += 40
      args.state.landed << b
    end
  end
  args.state.falling = args.state.falling.select{|b| b.vy > 0}
end

def add_block args
  args.state.falling << {
    x: rand(18)*40, y: (rand(2) + 30)*40, w: 40, h: 40,
    path: "sprites/circle/blue.png",
    vy: 10, vx: 0
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

  args.outputs.primitives << args.state.falling
  args.outputs.primitives << args.state.landed
end

