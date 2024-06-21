include("utils.jl")

@enum Cell::Int8 updown leftright upright upleft downleft downright ground start

function parse_input(input)
  lines = collect(Utils.lines(input))
  map = Matrix{Cell}(undef, length(lines), length(lines[1]))
  starting_point = (0, 0)
  for (y, l) in enumerate(lines)
    for (x, ch) in enumerate(l)
      el =
        if ch == '|' updown
        elseif ch == '-' leftright
        elseif ch == 'L' upright
        elseif ch == 'J' upleft
        elseif ch == '7' downleft
        elseif ch == 'F' downright
        elseif ch == '.' ground
        elseif ch == 'S'; starting_point = (y, x); start
        else error("Invalid symbol: $ch") end
      map[y, x] = el
    end
  end
  map, starting_point
end

function get_start_connections(map::Matrix{Cell}, (start_y, start_x))
  r = filter([
    (start_y - 1, start_x),
    (start_y, start_x - 1), (start_y, start_x + 1),
    (start_y + 1, start_x)
  ]) do (y, x)
    all((1, 1) .<= (y, x) .<= size(map)) || return false
    if y > start_y any(map[y, x] .== (upleft, upright, updown))
    elseif y < start_y any(map[y, x] .== (downleft, downright, updown))
    elseif x > start_x any(map[y, x] .== (leftright, downleft, upleft))
    elseif x < start_x any(map[y, x] .== (leftright, downright, upright))
    else false end
  end
  if length(r) > 2 @warn "Expected start to be connected to two pipes" end
  r
end

function find_loop((map, (start_y, start_x)))
  to_visit = [(start_y, start_x, 0)]
  main_loop = Dict{Tuple{Int64,Int64},Int64}()
  while !isempty(to_visit)
    cell_y, cell_x, dist = popfirst!(to_visit)
    cell = map[cell_y, cell_x]
    main_loop[(cell_y, cell_x)] = dist
    next =
      if cell == updown; [(cell_y - 1, cell_x), (cell_y + 1, cell_x)]
      elseif cell == leftright; [(cell_y, cell_x - 1), (cell_y, cell_x + 1)]
      elseif cell == upright; [(cell_y - 1, cell_x), (cell_y, cell_x + 1)]
      elseif cell == upleft; [(cell_y - 1, cell_x), (cell_y, cell_x - 1)]
      elseif cell == downleft; [(cell_y + 1, cell_x), (cell_y, cell_x - 1)]
      elseif cell == downright; [(cell_y + 1, cell_x), (cell_y, cell_x + 1)]
      elseif cell == start; get_start_connections(map, (cell_y, cell_x))
      else error("Invalid cell") end
    for (n_y, n_x) in next
      if haskey(main_loop, (n_y, n_x)) continue end
      push!(to_visit, (n_y, n_x, dist + 1))
    end
  end
  main_loop
end

function part1(data)
  loop = find_loop(data)
  maximum(values(loop))
end

function calc_start_cell(maze::Matrix{Cell}, start)
  a, b = map(p -> p .- start, get_start_connections(maze, start))
  if a == (-1, 0) && b == (1, 0)
    updown
  elseif a == (0, -1) && b == (0, 1)
    leftright
  elseif a == (-1, 0) && b == (0, -1)
    upleft
  elseif a == (-1, 0) && b == (0, 1)
    upright
  elseif a == (0, -1) && b == (1, 0)
    downleft
  elseif a == (0, 1) && b == (1, 0)
    downright
  else error("Invalid start cell") end
end

function part2(data)
  loop = find_loop(data)
  map, start_point = data
  max_y, max_x = size(map)
  # enclosed_map = Matrix{Int8}(undef, max_y, max_x)
  enclosed_area = 0
  start_cell = calc_start_cell(map, start_point)
  for y in 1:max_y
    crossed_walls = 0
    for x in 1:max_x
      is_loop_tile = haskey(loop, (y, x))
      if is_loop_tile
        cell = map[y, x]
        cell = cell == start ? start_cell : cell
        if cell == updown || cell == downleft || cell == downright
          crossed_walls += 1
        end
      elseif isodd(crossed_walls)
        enclosed_area += 1
      end
    end
  end
  enclosed_area
end

example_part1 = parse_input("""
  ..F7.
  .FJ|.
  SJ.L7
  |F--J
  LJ...
  """)
example_part2_1 = parse_input("""
  ...........
  .S-------7.
  .|F-----7|.
  .||.....||.
  .||.....||.
  .|L-7.F-J|.
  .|..|.|..|.
  .L--J.L--J.
  ...........
  """)
example_part2_2 = parse_input("""
  .F----7F7F7F7F-7....
  .|F--7||||||||FJ....
  .||.FJ||||||||L7....
  FJL7L7LJLJ||LJ.L-7..
  L--J.L7...LJS7F-7L7.
  ....F-J..F7FJ|L7L7L7
  ....L7.F7||L7|.L7L7|
  .....|FJLJ|FJ|F7|.LJ
  ....FJL-7.||.||||...
  ....L---J.LJ.LJLJ...
  """)
example_part2_3 = parse_input("""
  FF7FSF7F7F7F7F7F---7
  L|LJ||||||||||||F--J
  FL-7LJLJ||||||LJL-77
  F--JF--7||LJLJ7F7FJ-
  L---JF-JLJ.||-FJLJJ7
  |F|F-JF---7F7-L7L|7|
  |FFJF7L7F-JF7|JL---7
  7-L-JL7||F7|L7F-7F7|
  L.L7LFJ|||||FJL7||LJ
  L7JLJL-JLJLJL--JLJ.L
  """)
println("[Example p1] $(part1(example_part1))") # 8
println("[Example p2 (1)] $(part2(example_part2_1))") # 4
println("[Example p2 (2)] $(part2(example_part2_2))") # 8
println("[Example p2 (3)] $(part2(example_part2_3))") # 10

data = parse_input(Utils.readday(10))
println("[Part 1] $(part1(data))") # 6923
println("[Part 2] $(part2(data))") # 529
