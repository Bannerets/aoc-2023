include("utils.jl")

function parse_part1_input(input)
  times_raw, = match(r"Time:\s+(.+)", input)
  times = (parse(Int, x) for x in eachsplit(times_raw))
  distances_raw, = match(r"Distance:\s+(.+)", input)
  distances = (parse(Int, x) for x in eachsplit(distances_raw))
  zip(times, distances)
end

function parse_part2_input(input)
  times_raw, = match(r"Time:\s+(.+)", input)
  distances_raw, = match(r"Distance:\s+(.+)", input)
  time = parse(Int, join(eachsplit(times_raw)))
  distance = parse(Int, join(eachsplit(distances_raw)))
  (time, distance)
end

# the numbers are small, dumb solution
solve((time, dist)) = count(x -> x * (time - x) > dist, 1:time)

part1(input) = reduce(*, (solve(r) for r in parse_part1_input(input)))
part2(input) = solve(parse_part2_input(input))

example = """
  Time:      7  15   30
  Distance:  9  40  200
  """
println("[Example p1] $(part1(example))") # 288
println("[Example p2] $(part2(example))") # 71503

data = Utils.readday(6)
println("[Part 1] $(part1(data))") # 1195150
println("[Part 2] $(part2(data))") # 42550411
