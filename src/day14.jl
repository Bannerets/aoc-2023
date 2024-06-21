include("utils.jl")

function parse_input(input)
  lines = collect(Utils.lines(input))
  m = Matrix{Char}(undef, length(lines), length(lines[1]))
  for (y, l) in enumerate(lines), (x, ch) in enumerate(l)
    m[y, x] = ch
  end
  m
end

# seems to make no allocations!
function tilt(m::Matrix{Char}, y_dir::Int, x_dir::Int)
  y_iter = y_dir > 0 ? reverse(axes(m, 1)) : axes(m, 1)
  x_iter = x_dir > 0 ? reverse(axes(m, 2)) : axes(m, 2)
  y_end, x_end = size(m)
  function f(y::Int, x::Int)
    if m[y, x] == 'O'
      m[y, x] = '.'
      while 1 <= y + y_dir <= y_end && 1 <= x + x_dir <= x_end && m[y + y_dir, x + x_dir] == '.'
        y += y_dir
        x += x_dir
      end
      m[y, x] = 'O'
    end
  end
  if x_dir == 0
    for y in y_iter, x in x_iter f(y, x) end
  else
    for x in x_iter, y in y_iter f(y, x) end
  end
end

function calc_total_load(m::Matrix{Char})
  y_end = lastindex(axes(m, 1))
  reduce(
    +,
    y_end - y + 1 for (y, x) in Iterators.product(axes(m)...) if m[y, x] == 'O';
    init=0)
end

function part1(data)
  m = copy(data)
  tilt(m, -1, 0)
  calc_total_load(m)
end

function tilt_cycle(m::Matrix{Char})
  tilt(m, -1, 0)
  tilt(m, 0, -1)
  tilt(m, 1, 0)
  tilt(m, 0, 1)
end

function part2(data)
  m = copy(data)
  # for i in 1:10000
  #   println("Cycle $i")
  #   tilt_cycle(m)
  #   for row in eachrow(m) println(join(row)) end
  # end
  target = 1000000000
  dict = Dict{Matrix{Char}, Int}()
  i = 1
  r = -1
  while true
    tilt_cycle(m)
    if haskey(dict, m)
      if r < 0
        r = i - dict[m]
        println("Found a repetition in cycle $i, r=$r, size $(length(dict))")
      end
    else
      dict[m] = i
    end
    if r > 0 && (target - i) % r == 0
      return calc_total_load(m)
    end
    i += 1
  end
end

example = parse_input("""
  O....#....
  O.OO#....#
  .....##...
  OO.#O....O
  .O.....O#.
  O.#..O.#.#
  ..O..#O..O
  .......O..
  #....###..
  #OO..#....
  """)
println("[Example p1] $(part1(example))") # 136
println("[Example p2] $(part2(example))") # 64

data = parse_input(Utils.readday(14))
println("[Part 1] $(part1(data))") # 113456
println("[Part 2] $(part2(data))") # 118747
