include("utils.jl")

function parse_input(input)
  result = Matrix{Char}[]
  for pat in eachsplit(input, r"\r?\n\r?\n"; keepempty=false)
    lines = collect(Utils.lines(pat))
    m = Matrix{Char}(undef, length(lines), length(lines[1]))
    for (y, l) in enumerate(lines), (x, ch) in enumerate(l)
      m[y, x] = ch
    end
    push!(result, m)
  end
  result
end

function find_reflection(m::Matrix{Char}; ignore=(-2,-2))::Tuple{Int,Int}
  max_y, max_x = size(m)
  for (x1, x2) in zip(1:max_x-1, 2:max_x)
    (x1, -1) == ignore && continue
    if all(m[:,x1-a:x1-a] == m[:,x2+a:x2+a] for a in 0:min(max_x-x2,x1-1))
      return (x1, -1)
    end
  end
  for (y1, y2) in zip(1:max_y-1, 2:max_y)
    (-1, y1) == ignore && continue
    if all(m[y1-a:y1-a,:] == m[y2+a:y2+a,:] for a in 0:min(max_y-y2,y1-1))
      return (-1, y1)
    end
  end
  return (-1, -1)
end

reflection_score((x_res, y_res)::Tuple{Int,Int}) =
  if x_res != -1; x_res
  elseif y_res != -1; 100 * y_res
  else 0 end

part1(patterns) =
  reduce(+, reflection_score(find_reflection(m)) for m in patterns; init=0)

invert(ch::Char) = ch == '#' ? '.' : '#'

part2(patterns) =
  reduce(+, Iterators.map(patterns) do m
    part1_refl = find_reflection(m)
    for i in eachindex(m)
      m[i] = invert(m[i])
      refl = find_reflection(m; ignore=part1_refl)
      m[i] = invert(m[i])
      if refl != (-1, -1) return reflection_score(refl) end
    end
    return 0
  end; init=0)

example = parse_input("""
  #.##..##.
  ..#.##.#.
  ##......#
  ##......#
  ..#.##.#.
  ..##..##.
  #.#.##.#.

  #...##..#
  #....#..#
  ..##..###
  #####.##.
  #####.##.
  ..##..###
  #....#..#
  """)
println("[Example p1] $(part1(example))") # 405
println("[Example p2] $(part2(example))") # 400

data = parse_input(Utils.readday(13))
@time println("[Part 1] $(part1(data))") # 37561
@time println("[Part 2] $(part2(data))") # 31108
