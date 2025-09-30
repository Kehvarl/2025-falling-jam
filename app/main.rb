def init args
    args.state.cats = {}
    args.state.dropper = {
        x: 360, y: 1250, w: 40, h: 20,
        color: "green",
        path: "sprites/square/green.png",
    }
    args.state.falling = nil
end

def set_dropper args, color
    args.state.dropper.color = color
    args.state.dropper.path = "sprites/square/#{color}.png"
end

def add_block args, color="blue"
    x = args.state.dropper.x.div(40).to_int
    y = 31
    args.state.falling = {
        x: x*40, y: y*40, w: 40, h: 40,
        path: "sprites/circle/#{color}.png",
        moved: true,
        vy: 10, vx: 0, to_remove: false, color: color
    }
    args.state.cats[[x,y]] = args.state.falling
end

def calculate_physics args
    # drop all that can drop
    new_grid = {}
    args.state.cats.keys.sort_by { |k| k[1] }.each do |key|
        x,y = key
        cat = args.state.cats[key]
        if (y > 0) and not new_grid.has_key?([x,y-1])
            y = [y-1, 0].max
            cat.y = (y * 40).to_int
            cat.moved = true
            new_grid[[x,y]] = cat
        else
            if cat == args.state.falling
                args.state.falling = nil
            end
            cat.moved = false
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
    # Landed cat adjacent to different color teleports both away
    (0..31).each do |y|
        deleting = false
        (0..15).each do |x|
            if args.state.cats.has_key?([x,y]) and not args.state.cats[[x,y]].moved
                cat = args.state.cats[[x,y]]
                if deleting or (args.state.cats.has_key?([x+1,y]) and (args.state.cats[[x+1,y]].color != cat.color) and not args.state.cats[[x+1,y]].moved)
                    deleting = true
                    to_remove << [x,y]
                end
            else
                deleting = false
            end
        end
    end

    to_remove.uniq.each {|c| args.state.cats.delete(c)}
end


def process_inputs args
    # Move the dropper, or the dropped?
    # Drop and forget, or Tetris style?
    x,y = args.state.cats.key(args.state.falling)
    nx = x
    if args.inputs.keyboard.key_down.right
        if args.state.falling
            args.state.falling.x += 40
            nx += 1
        else
            args.state.dropper.x += 40
        end
    elsif args.inputs.keyboard.key_down.left
        if args.state.falling
            args.state.falling.x -= 40
            nx -= 1
        else
            args.state.dropper.x -= 40
        end
    end
    if args.state.falling
        args.state.cats.delete([x,y])
        args.state.cats[[nx,y]] = args.state.falling
    end

    if args.inputs.keyboard.key_down.up
        colors = ["red", "blue", "green", "white"]
        if args.state.falling
            i = colors.index(args.state.falling.color)
            c = colors[(i + 1) % colors.length]
            args.state.falling.color = c
            args.state.falling.path = "sprites/circle/#{c}.png"
        end
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
