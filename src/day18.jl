include("utils.jl")

struct Row
  dir::Char
  dist::Int
  color::String
end

function parse_input(input)
  result = Row[]
  for l in Utils.lines(input)
    dir, dist, color = match(r"(\w) (\d+) \(#([\dabcdef]+)\)", l)
    push!(result, Row(dir[1], parse(Int, dist), color))
  end
  result
end

parse_dir(dir::Char)::Tuple{Int16,Int16} =
  if dir == 'L' || dir == '2'; (0, -1)
  elseif dir == 'R' || dir == '0'; (0, 1)
  elseif dir == 'U' || dir == '3'; (-1, 0)
  elseif dir == 'D' || dir == '1'; (1, 0)
  else error("Invalid direction: $dir") end

function part1(input)
  trench = Set{Tuple{Int16,Int16}}()
  push!(trench, (0, 0))
  min_x, max_x, min_y, max_y = Int16(0), Int16(0), Int16(0), Int16(0)
  position::Tuple{Int16,Int16} = (0, 0)
  for (; dir, dist) in input
    move = parse_dir(dir)
    for _ in 1:dist
      position = position .+ move
      push!(trench, position)
    end
    min_y = min(min_y, position[1])
    max_y = max(max_y, position[1])
    min_x = min(min_x, position[2])
    max_x = max(max_x, position[2])
  end
  area = 0
  for y in min_y:max_y
    inside = false
    prev = false
    for x in min_x:max_x
      # Count interior very similarly to aoc day 10
      if (y, x) in trench
        if !prev && (y, x + 1) in trench && (y + 1, x) in trench
          inside = !inside
        end
        prev = true
        area += 1
      else
        if prev && (y + 1, x - 1) in trench
          inside = !inside
        end
        prev = false
        if inside; area += 1 end
      end
    end
  end
  # m = Matrix{Char}(undef, abs(max_y - min_y) + 1, abs(max_x - min_x) + 1)
  # for y in min_y:max_y, x in min_x:max_x
  #   m[y - min_y + 1, x - min_x + 1] = (y, x) in trench ? '#' : '.'
  # end
  # for r in eachrow(m); println(join(r)) end
  area
end

function part2(input)
  position::Tuple{Int,Int} = (0, 0)
  area::Int = 0
  trench::Int = 0
  for (; color) in input
    dir_offset = parse_dir(color[end])
    dist = parse(Int, color[begin:end-1]; base=16)
    next_position = position .+ (dir_offset .* dist)
    (a, b) = position
    (c, d) = next_position
    # Shoelace formula
    area += (d - b) * (c + a) ÷ 2
    trench += abs((d - b) + (c - a))
    position = next_position
  end
  # By Pick's theorem, `area` already includes trench/2 - 1
  abs(area) + trench ÷ 2 + 1
end

example = parse_input("""
  # R 6 (#70c710)
  # D 5 (#0dc571)
  # L 2 (#5713f0)
  # D 2 (#d2c081)
  # R 2 (#59c680)
  # D 2 (#411b91)
  # L 5 (#8ceee2)
  # U 2 (#caa173)
  # L 1 (#1b58a2)
  # U 2 (#caa171)
  # R 2 (#7807d2)
  # U 3 (#a77fa3)
  # L 2 (#015232)
  # U 2 (#7a21e3)
  """)
println("[Example p1] $(part1(example))") # 62
println("[Example p2] $(part2(example))") # 952408144115

data = parse_input(Utils.readday(18))
@time println("[Part 1] $(part1(data))") # 35401
@time println("[Part 2] $(part2(data))") # 48020869073824
