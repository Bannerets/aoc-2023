include("utils.jl")

struct Point
  y::Int16
  x::Int16
end

function parse_input(input)::Tuple{Matrix{Char},Point}
  lines = collect(Utils.lines(input))
  m = Matrix{Char}(undef, length(lines), length(lines[1]))
  start = Point(0, 0)
  for (y, l) in enumerate(lines), (x, ch) in enumerate(l)
    m[y, x] = ch == 'S' ? '.' : ch
    if ch == 'S' start = Point(y, x) end
  end
  m, start
end

const AdjacentOffsets = Tuple{Int, Int}[(-1, 0), (1, 0), (0, -1), (0, 1)]

function part1((m, start); steps=64)
  neighbors(p::Point) =
    (Point(a + p.y, b + p.x) for (a, b) in AdjacentOffsets
      if 1 <= a + p.y <= size(m, 1) && 1 <= b + p.x <= size(m, 2) &&
        m[a + p.y, b + p.x] != '#')
  cursors = Set{Point}()
  new_cursors = Set{Point}()
  push!(cursors, start)
  for _ in 1:steps
    for p in cursors
      for n in neighbors(p)
        push!(new_cursors, n)
      end
    end
    cursors, new_cursors = new_cursors, cursors
    empty!(new_cursors)
  end
  length(cursors)
end

function part2((m, start); steps=26501365)
  max_y, max_x = size(m, 1), size(m, 2)
  mod_y(y) = mod(y - 1, max_y) + 1
  mod_x(x) = mod(x - 1, max_x) + 1
  neighbors(p::Point) =
    (Point(a + p.y, b + p.x) for (a, b) in AdjacentOffsets
      if m[mod_y(a + p.y), mod_x(b + p.x)] != '#')
  cursors = Set{Point}()
  new_cursors = Set{Point}()
  push!(cursors, start)
  answer_65 = 0 # from start to the end of the start tile
  answer_196 = 0 # 65 + 131; start tile + 1 tile
  answer_327 = 0 # 65 + 2 * 131; start tile + 2 tiles
  for i in 1:steps
    for p in cursors
      for n in neighbors(p)
        push!(new_cursors, n)
      end
    end
    cursors, new_cursors = new_cursors, cursors
    empty!(new_cursors)
    if i == 65 answer_65 = length(cursors)
    elseif i == 196 answer_196 = length(cursors)
    elseif i == 327
      answer_327 = length(cursors)
      break
    end
  end
  @show answer_65 answer_196 answer_327
  needed_tiles = (steps - 65) ÷ 131 # 202300 for steps=26501365
  diff_1 = answer_196 - answer_65
  diff_2 = answer_327 - answer_196
  tiles_sum = needed_tiles * (needed_tiles - 1) ÷ 2
  @show diff_1 diff_2 (diff_2 - diff_1) tiles_sum
  (diff_2 - diff_1) * tiles_sum + diff_1 * needed_tiles + answer_65
end

example = parse_input("""
  ...........
  .....###.#.
  .###.##..#.
  ..#.#...#..
  ....#.#....
  .##..S####.
  .##..#...#.
  .......##..
  .##.#.####.
  .##..##.##.
  ...........
  """)
println("[Example p1] $(part1(example))") # 42

data = parse_input(Utils.readday(21))
@time println("[Part 1] $(part1(data))") # 3847
@time println("[Part 2] $(part2(data))") # 637537341306357
