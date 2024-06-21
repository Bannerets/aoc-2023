include("utils.jl")

@enum Cell::Int8 galaxy empty

function parse_input(input)
  lines = collect(Utils.lines(input))
  img = Matrix{Cell}(undef, length(lines), length(lines[1]))
  galaxies::Vector{Tuple{Int, Int}} = []
  for (y, l) in enumerate(lines)
    for (x, ch) in enumerate(l)
      if ch == '#'
        img[y, x] = galaxy
        push!(galaxies, (y, x))
      elseif ch == '.'
        img[y, x] = empty
      else error("Unknown symbol $ch") end
    end
  end
  img, galaxies
end

function calc_paths((img, galaxies), empty_multiplier)
  empty_rows, empty_cols = Int[], Int[]
  for (y, r) in enumerate(eachrow(img))
    if all(r .== empty) push!(empty_rows, y) end
  end
  for (x, c) in enumerate(eachcol(img))
    if all(c .== empty) push!(empty_cols, x) end
  end
  result = 0
  for (i, (yy1, xx1)) in enumerate(galaxies)
    for (yy2, xx2) in galaxies[i+1:end]
      y1, y2 = minmax(yy1, yy2)
      x1, x2 = minmax(xx1, xx2)
      empty_ys = count(y -> y1 < y < y2, empty_rows) * (empty_multiplier - 1)
      empty_xs = count(x -> x1 < x < x2, empty_cols) * (empty_multiplier - 1)
      result += (y2 + empty_ys - y1) + (x2 + empty_xs - x1)
    end
  end
  result
end

part1(data) = calc_paths(data, 2)
part2(data; empty_multiplier=1000000) = calc_paths(data, empty_multiplier)

example = parse_input("""
  ...#......
  .......#..
  #.........
  ..........
  ......#...
  .#........
  .........#
  ..........
  .......#..
  #...#.....
  """)
println("[Example p1] $(part1(example))") # 374
println("[Example p2] $(part2(example, empty_multiplier=100))") # 8410

data = parse_input(Utils.readday(11))
println("[Part 1] $(part1(data))") # 10276166
println("[Part 2] $(part2(data))") # 598693078798
