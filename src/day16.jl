include("utils.jl")

function parse_input(input)::Matrix{Char}
  lines = collect(Utils.lines(input))
  m = Matrix{Char}(undef, length(lines), length(lines[1]))
  for (y, l) in enumerate(lines), (x, ch) in enumerate(l)
    m[y, x] = ch
  end
  m
end

mutable struct Beam
  x::Int16
  y::Int16
  vx::Int8
  vy::Int8
  done::Bool
end

function part1(m; initial_beam=Beam(1, 1, 1, 0, false))
  max_y, max_x = size(m)
  possible_beams = Set{Tuple{Int16,Int16,Int8,Int8}}()
  beams = [initial_beam]
  while true
    in_progress = false
    for beam in beams
      if beam.done continue end
      if !(1 <= beam.y <= max_y && 1 <= beam.x <= max_x) ||
          (beam.x, beam.y, beam.vx, beam.vy) in possible_beams
        beam.done = true
        continue
      end
      in_progress = true
      cell = m[beam.y, beam.x]
      push!(possible_beams, (beam.x, beam.y, beam.vx, beam.vy))
      if cell == '/'
        beam.vx, beam.vy = -beam.vy, -beam.vx
      elseif cell == '\\'
        beam.vx, beam.vy = beam.vy, beam.vx
      elseif cell == '|' && beam.vx != 0 && beam.vy == 0
        beam.vx, beam.vy = 0, 1
        push!(beams, Beam(beam.x, beam.y - 1, 0, -1, false))
      elseif cell == '-' && beam.vx == 0 && beam.vy != 0
        beam.vx, beam.vy = 1, 0
        push!(beams, Beam(beam.x - 1, beam.y, -1, 0, false))
      end
      beam.y += beam.vy
      beam.x += beam.vx
    end
    if !in_progress break end
  end
  # for (y, x) in energized m[y, x] = '#' end
  # for row in eachrow(m) println(join(row)) end
  length(unique(((x, y, _, _),) -> (x, y), possible_beams))
end

function part2(m)
  max_energizing = 0
  max_y, max_x = size(m)
  for y in 1:max_y
    left = part1(m; initial_beam=Beam(1, y, 1, 0, false))
    right = part1(m; initial_beam=Beam(max_x, y, -1, 0, false))
    max_energizing = max(max_energizing, left, right)
  end
  for x in 1:max_x
    top = part1(m; initial_beam=Beam(x, 1, 0, 1, false))
    bot = part1(m; initial_beam=Beam(x, max_y, 0, -1, false))
    max_energizing = max(max_energizing, top, bot)
  end
  max_energizing
end

example = parse_input(raw"""
  .|...\....
  |.-.\.....
  .....|-...
  ........|.
  ..........
  .........\
  ..../.\\..
  .-.-/..|..
  .|....-|.\
  ..//.|....
  """)
println("[Example p1] $(part1(example))") # 46
println("[Example p2] $(part2(example))") # 51

data = parse_input(Utils.readday(16))
@time println("[Part 1] $(part1(data))") # 6978
@time println("[Part 2] $(part2(data))") # 7315
