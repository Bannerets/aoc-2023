include("utils.jl")

function parse_input(input)::Matrix{Int8}
  lines = collect(Utils.lines(input))
  m = Matrix{Char}(undef, length(lines), length(lines[1]))
  for (y, l) in enumerate(lines), (x, ch) in enumerate(l)
    m[y, x] = parse(Int8, ch)
  end
  m
end

struct BinaryHeap{T}
  data::Vector{Tuple{Int,T}}
end

BinaryHeap{T}() where {T} = BinaryHeap(Tuple{Int,T}[])

function insert!((; data)::BinaryHeap{T}, priority::Integer, el::T) where T
  push!(data, (priority, el))
  i = lastindex(data)
  while true
    parent = i ÷ 2
    if parent >= 1 && data[parent][1] > data[i][1]
      data[i], data[parent] = data[parent], data[i]
      i = parent
    else break end
  end
end

function popmin!((; data)::BinaryHeap{T})::Tuple{Int,T} where T
  min = data[begin]
  data[begin] = data[end]
  pop!(data)
  i = 1
  while true
    left = 2 * i
    right = 2 * i + 1
    smallest = i
    if left <= length(data) && data[left][1] < data[smallest][1]
      smallest = left
    end
    if right <= length(data) && data[right][1] < data[smallest][1]
      smallest = right
    end
    if smallest != i
      data[i], data[smallest] = data[smallest], data[i]
      i = smallest
    else break end
  end
  min
end

isempty((; data)::BinaryHeap{})::Bool = Base.isempty(data)

@enum Dir::Int8 hor=0 ver=1
invert_dir(dir::Dir)::Dir = dir == hor ? ver : hor

struct Vertex y::Int16; x::Int16; dir::Dir end
Base.iterate(v::Vertex, n=1) =
  if n <= fieldcount(Vertex); getfield(v, n), n + 1 end

function findshortest(m::Matrix{Int8}, single_dir::UnitRange{Int})::Int
  # Dijkstra's algorithm
  #
  # Shortly: The cells are divided into two "virtual" vertices, horizontal and
  # vertical. The edges connect horizontal and vertical vertices only; that is,
  # during movement, only rotations can happen. Horizontal vertices are
  # connected to vertical vertices on the x-axis and vertical vertices are
  # connected to horizontal vertices on the y-axis. Edges also connect more
  # distant vertices as much as the limit of movement in a straight line allows.
  max_y, max_x = size(m)
  function neighbors(start_y::Int16, start_x::Int16, dir::Dir)
    bounds(y, x) = 1 <= start_y + y <= max_y && 1 <= start_x + x <= max_x
    step(x) = sign(x) == 0 ? 1 : sign(x)
    calc_cost_to(t_y, t_x) =
      reduce(+,
        m[start_y + y, start_x + x]
          for y in sign(t_y):step(t_y):t_y, x in sign(t_x):step(t_x):t_x)
    single_coord_moves = (s * c for c in single_dir for s in -1:2:1)
    possible_moves = dir == ver ?
      ((y, 0) for y in single_coord_moves if bounds(y, 0)) :
      ((0, x) for x in single_coord_moves if bounds(0, x))
    ((Vertex(start_y + y, start_x + x, invert_dir(dir)), calc_cost_to(y, x))
      for (y, x) in possible_moves)
  end
  queue = BinaryHeap{Vertex}()
  dists_hor = [typemax(Int32) for _ in 1:max_y, _ in 1:max_x]
  dists_ver = [typemax(Int32) for _ in 1:max_y, _ in 1:max_x]
  get_dists((y, x, dir)::Vertex) =
    dir == hor ? dists_hor[y, x] : dists_ver[y, x]
  set_dists((y, x, dir)::Vertex, v) =
    dir == hor ? dists_hor[y, x] = v : dists_ver[y, x] = v
  dists_hor[1, 1] = 0
  dists_ver[1, 1] = 0
  insert!(queue, 0, Vertex(1, 1, hor))
  insert!(queue, 0, Vertex(1, 1, ver))
  times_goal_visited = 0
  while !isempty(queue)
    priority, cur = popmin!(queue)
    cur_dist = get_dists(cur)
    if priority != cur_dist continue end
    if (cur.y, cur.x) == (max_y, max_x)
      times_goal_visited += 1
      if times_goal_visited >= 2 break end
    end
    for (next, cost) in neighbors(cur.y, cur.x, cur.dir)
      next_dist = get_dists(next)
      alt_dist = cur_dist + cost
      if alt_dist < next_dist
        set_dists(next, alt_dist)
        insert!(queue, alt_dist, next)
      end
    end
  end
  min(dists_hor[max_y, max_x], dists_ver[max_y, max_x])
end

part1(m::Matrix{Int8}) = findshortest(m, 1:3)
part2(m::Matrix{Int8}) = findshortest(m, 4:10)

example = parse_input("""
  2413432311323
  3215453535623
  3255245654254
  3446585845452
  4546657867536
  1438598798454
  4457876987766
  3637877979653
  4654967986887
  4564679986453
  1224686865563
  2546548887735
  4322674655533
  """)
@time println("[Example p1] $(part1(example))") # 102
@time println("[Example p2] $(part2(example))") # 94

data = parse_input(Utils.readday(17))
@time println("[Part 1] $(part1(data))") # 1238
@time println("[Part 2] $(part2(data))") # 1362

# Before priority queues via heaps, part1 = 0.12s, part2 = 0.60s on my machine.
# After, it executes in part1 = 0.02s, part2 = 0.04s on my machine.
# The result makes only 23 allocations.
