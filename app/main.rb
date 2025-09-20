def init args
    args.state.cats = {}
    args.state.dropper = {
        x: 360, y: 1250, w: 40, h: 20,
        path: "sprites/square/green.png",
    }
end

def add_block args
    x = args.state.dropper.x
    y = 1210
    args.state.cats[[x,y]] = {
        x: x, y: y, w: 40, h: 40,
        path: "sprites/circle/blue.png",
        vy: 10, vx: 0
    }
end

def calculate_physics args
    new_grid = {}
    args.state.cats.each do |c|
        x,y = c[0]
        if not args.state.cats.has_key?([x,y-1])
            y -= 1
            cat = c[1]
            cat.y -= 40
            new_grid[[x,y]] = cat
        end
    end
end

def check_rules args
    # Landed cat on cat of same color teleports both away
    # Landed cat adjacent to different color teleports both away
    #
end

def process_inputs args
    if args.inputs.keyboard.right
        args.state.dropper.x += 40
    elsif args.inputs.keyboard.left
        args.state.dropper.x -= 40
    end
    if args.inputs.keyboard.space
        add_block(args)
    end
end

def render args
    args.outputs.primitives << args.state.dropper
    args.state.cats.each do |c|
        args.outputs.primitives << c[1]
    end
end

def tick args
    if args.tick_count == 0
        init(args)
        add_block(args)
    end
    process_inputs(args)
    calculate_physics(args)
    check_rules(args)

    render(args)
end
