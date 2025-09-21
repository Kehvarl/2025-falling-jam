def init args
    args.state.cats = {}
    args.state.dropper = {
        x: 360, y: 1250, w: 40, h: 20,
        color: "green",
        path: "sprites/square/green.png",
    }
end

def set_dropper args, color
    args.state.dropper.color = color
    args.state.dropper.path = "sprites/square/#{color}.png"
end

def add_block args, color="blue"
    x = args.state.dropper.x/40
    y = 31
    args.state.cats[[x,y]] = {
        x: x*40, y: y*40, w: 40, h: 40,
        path: "sprites/circle/#{color}.png",
        vy: 10, vx: 0, to_remove: false, color: color
    }
end

def calculate_physics args
    new_grid = {}
    args.state.cats.keys.sort_by { |k| k[1] }.each do |key|
        x,y = key
        cat = args.state.cats[key]
        if not new_grid.has_key?([x,y-1])
            y = [y-1, 0].max
            cat.y = y * 40
            new_grid[[x,y]] = cat
        else
            new_grid[[x,y]] = cat
        end
    end
    args.state.cats = new_grid
end

def check_rules args
    # Landed cat on cat of same color teleports both away
    to_remove = []
    args.state.cats.keys.sort_by { |k| k[1] }.each do |key|
        x,y = key
        cat = args.state.cats[key]
        if y == 0
            next
        else
            if args.state.cats.has_key?([x,y-1])
                c2 = args.state.cats[[x,y-1]]
                if c2.color == cat.color
                    to_remove << [x,y]
                    to_remove << [x,y-1]
                end
            end
        end
    end
    to_remove.uniq.each {|c| args.state.cats.delete(c)}
    # Landed cat adjacent to different color teleports both away
end

def process_inputs args
    if args.inputs.keyboard.key_down.right
        args.state.dropper.x += 40
    elsif args.inputs.keyboard.key_down.left
        args.state.dropper.x -= 40
    end
    args.state.dropper.x = args.state.dropper.x.clamp(0,680)
    if args.inputs.keyboard.key_down.space
        add_block(args, args.state.dropper.color)
        set_dropper(args, ["red", "blue", "green", "white"].sample())
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
