include("utils.jl")

function parse_input(input)
  lines = collect(Utils.lines(input))
  m = Matrix{Char}(undef, length(lines), length(lines[1]))
  for (y, l) in enumerate(lines), (x, ch) in enumerate(l)
    m[y, x] = ch
  end
  m
end

struct Point
  y::Int16
  x::Int16
end

const adjacent_offsets = [(0, 1), (0, -1), (1, 0), (-1, 0)]

function part1_neighbors(m, (; y, x)::Point)
  max_y, max_x = size(m)
  [Point(y + oy, x + ox)
    for (oy, ox) in adjacent_offsets
    if 1 <= y + oy <= max_y && 1 <= x + ox <= max_x && m[y + oy, x + ox] != '#']
end

function part1(m)
  goal_row = size(m, 1)
  goal_column = nothing
  distances = Dict{Point,Int}()
  stack = Tuple{Point, Int}[]
  push!(stack, (Point(1, 2), 0))
  while !isempty(stack)
    p, dist = pop!(stack)
    recorded_dist = haskey(distances, p) ? distances[p] : 0
    if recorded_dist > dist continue end
    distances[p] = dist
    if p.y == goal_row
      goal_column = p.x
      continue
    end
    for p_n in part1_neighbors(m, p)
      if haskey(distances, p_n) && distances[p_n] >= dist - 1 continue end
      if m[p_n.y, p_n.x] == '>' && p_n.x <= p.x continue end
      if m[p_n.y, p_n.x] == '<' && p_n.x >= p.x continue end
      if m[p_n.y, p_n.x] == 'v' && p_n.y <= p.y continue end
      if m[p_n.y, p_n.x] == '^' && p_n.y >= p.y continue end
      push!(stack, (p_n, dist + 1))
    end
  end
  if isnothing(goal_column) error("Has not reached the goal") end
  distances[Point(goal_row, goal_column)]
end

function print_maps(m, explored)
  for (y, row) in enumerate(eachrow(m))
    str = ""
    for (x, ch) in enumerate(row)
      str *= explored[y, x] == 1 ? 'O' : ch
    end
    println(str)
  end
end

# part2 executes in ~7 minutes on my machine
function part2(input)
  init_map::Matrix{Int8} = fill(Int8(-1), size(input))
  for (i, ch) in enumerate(input)
    # 0 = empty, 1 = explored, 2 = wall
    init_map[i] = ch == '#' ? 2 : 0
  end
  goal_row = size(init_map, 1)
  goal_distance = 0
  stack = Tuple{Point, Matrix{Int8}, Int}[]
  push!(stack, (Point(2, 2), init_map, 1))
  while !isempty(stack)
    p, m, dist = pop!(stack)
    @label again
    if p.y == goal_row
      goal_distance = max(goal_distance, dist)
      continue
    elseif p.y == 1 continue end
    m[p.y, p.x] = 1
    if dist == 6600 println(dist); print_maps(input, m) end
    neighbor_a = m[p.y - 1, p.x] == 0
    neighbor_b = m[p.y + 1, p.x] == 0
    neighbor_c = m[p.y, p.x - 1] == 0
    neighbor_d = m[p.y, p.x + 1] == 0
    neighbors_len =
      Int(neighbor_a) + Int(neighbor_b) + Int(neighbor_c) + Int(neighbor_d)
    if neighbors_len == 1
      if neighbor_a; p = Point(p.y - 1, p.x)
      elseif neighbor_b; p = Point(p.y + 1, p.x)
      elseif neighbor_c; p = Point(p.y, p.x - 1)
      elseif neighbor_d; p = Point(p.y, p.x + 1) end
      dist += 1
      @goto again
    else
      i = 0
      if neighbor_d
        push!(stack, (Point(p.y, p.x + 1), m, dist + 1))
        i += 1
      end
      if neighbor_c
        push!(stack, (Point(p.y, p.x - 1), i > 0 ? copy(m) : m, dist + 1))
        i += 1
      end
      if neighbor_b
        push!(stack, (Point(p.y + 1, p.x), i > 0 ? copy(m) : m, dist + 1))
        i += 1
      end
      if neighbor_a
        push!(stack, (Point(p.y - 1, p.x), i > 0 ? copy(m) : m, dist + 1))
      end
    end
  end
  if goal_distance == 0 error("Has not reached the goal") end
  goal_distance
end

example = parse_input("""
  #.#####################
  #.......#########...###
  #######.#########.#.###
  ###.....#.>.>.###.#.###
  ###v#####.#v#.###.#.###
  ###.>...#.#.#.....#...#
  ###v###.#.#.#########.#
  ###...#.#.#.......#...#
  #####.#.#.#######.#.###
  #.....#.#.#.......#...#
  #.#####.#.#.#########v#
  #.#...#...#...###...>.#
  #.#.#v#######v###.###v#
  #...#.>.#...>.>.#.###.#
  #####v#.#.###v#.#.###.#
  #.....#...#...#.#.#...#
  #.#########.###.#.#.###
  #...###...#...#...#.###
  ###.###.#.###v#####v###
  #...#...#.#.>.>.#.>.###
  #.###.###.#.###.#.#v###
  #.....###...###...#...#
  #####################.#
  """)
println("[Example p1] $(part1(example))") # 94
println("[Example p2] $(part2(example))") # 154
@time println("[Example p2] $(part2(example))") # 154

data = parse_input(Utils.readday(23))
@time println("[Part 1] $(part1(data))") # 2074
@time println("[Part 2] $(part2(data))") # 6494
