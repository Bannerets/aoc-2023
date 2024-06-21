include("utils.jl")

function parse_input(input)
  local instrs
  nodes::Dict{String, Vector{String}} = Dict()
  for (i, l) in enumerate(Utils.lines(input))
    if i == 1
      instrs = collect(x == 'R' ? 2 : 1 for x in l)
    else
      node, l, r = match(r"^(.+) = \((.+), (.+)\)$", l)
      nodes[node] = [l, r]
    end
  end
  instrs, nodes
end

function part1((instrs, nodes))
  curnode, ip, steps = "AAA", 1, 0
  while curnode != "ZZZ"
    curnode = nodes[curnode][instrs[ip]]
    steps += 1
    ip += 1
    if ip > length(instrs); ip = 1 end
  end
  steps
end

function part2((instrs, nodes))
  steps = 0
  curnodes = collect(filter(s -> endswith(s, 'A'), keys(nodes)))
  cycles = Dict(map(x -> (x, -1), eachindex(curnodes)))
  finished = 0
  while finished < length(curnodes)
    steps += 1
    for (i, curnode) in enumerate(curnodes)
      if cycles[i] > 0 continue end
      curnodes[i] = nodes[curnode][instrs[mod1(steps, length(instrs))]]
      if endswith(curnodes[i], 'Z')
        cycles[i] = steps
        finished += 1
        @show curnodes[i], steps
      end
    end
  end
  lcm(values(cycles)...)
end

example_part1 = parse_input("""
  RL

  AAA = (BBB, CCC)
  BBB = (DDD, EEE)
  CCC = (ZZZ, GGG)
  DDD = (DDD, DDD)
  EEE = (EEE, EEE)
  GGG = (GGG, GGG)
  ZZZ = (ZZZ, ZZZ)
  """)
example_part2 = parse_input("""
  LR

  11A = (11B, XXX)
  11B = (XXX, 11Z)
  11Z = (11B, XXX)
  22A = (22B, XXX)
  22B = (22C, 22C)
  22C = (22Z, 22Z)
  22Z = (22B, 22B)
  XXX = (XXX, XXX)
  """)
println("[Example p1] $(part1(example_part1))") # 2
println("[Example p2] $(part2(example_part2))") # 6

data = parse_input(Utils.readday(8))
println("[Part 1] $(part1(data))") # 12361
println("[Part 2] $(part2(data))") # 18215611419223
