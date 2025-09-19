def init args
  args.state.falling = []
  args.state.landed = []
  args.state.dropper = {
    x: 360, y: 1250, w: 40, h: 20,
    path: "sprites/square/green.png",
  }
  args.state.heights = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
  args.state.drop_counter = 45
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

def check_block args, b
  # Block is different color from block below, else destroy both
  # All touching blocks in row are same color, else destroy all
  # Each row is shorter than the below row, else cannot win
  # Tallest possible:  15
end


def add_block args
  args.state.falling << {
    x: args.state.dropper.x, y: 1210, w: 40, h: 40,
    path: "sprites/circle/blue.png",
    vy: 10, vx: 0
    }
end

def tick args
  if args.tick_count == 0
    init(args)
    add_block(args)
  end
  args.state.drop_counter -=1

  if args.inputs.keyboard.key_down.left
    args.state.dropper.x -= 40
  elsif args.inputs.keyboard.key_down.right
    args.state.dropper.x += 40
  end

  if args.state.drop_counter <= 0 and (args.inputs.keyboard.space or args.inputs.mouse.button_left)
    add_block(args)
    args.state.drop_counter = 45
  end

  args.state.dropper.x = args.state.dropper.x.clamp(0,680)

  calc_physics(args)

  args.outputs.primitives << args.state.dropper
  args.outputs.primitives << args.state.falling
  args.outputs.primitives << args.state.landed
end

