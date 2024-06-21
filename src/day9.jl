include("utils.jl")

parse_input(input)::Vector{Vector{Int}} =
  collect(
    map(x -> parse(Int, x), eachsplit(l))
    for l in Utils.lines(input))

function run(input)
  part1_result, part2_result = 0, 0
  for history in input
    stack = [history]
    seq = history
    while any(x -> x != 0, seq)
      seq = map(((a, b),) -> b - a, zip(seq, seq[2:end]))
      push!(stack, seq)
    end
    next, prev = 0, 0
    while !isempty(stack)
      seq = pop!(stack)
      next += seq[end]
      prev = seq[1] - prev
    end
    part1_result += next
    part2_result += prev
  end
  part1_result, part2_result
end

part1(input) = first(run(input))
part2(input) = last(run(input))

example = parse_input("""
  0 3 6 9 12 15
  1 3 6 10 15 21
  10 13 16 21 30 45
  """)
println("[Example p1] $(part1(example))") # 114
println("[Example p2] $(part2(example))") # 2

data = parse_input(Utils.readday(9))
println("[Part 1] $(part1(data))") # 1637452029
println("[Part 2] $(part2(data))") # 908
