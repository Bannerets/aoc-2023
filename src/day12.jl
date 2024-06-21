include("utils.jl")

@enum Cell operational damaged unknown

struct Row
  springs::Vector{Cell}
  damaged_sizes::Vector{Int}
end

function parse_input(input)
  rows = Row[]
  for l in Utils.lines(input)
    springs_raw, sizes_raw = split(l, " ")
    springs = Iterators.map(springs_raw) do ch
      if ch == '.'; operational
      elseif ch == '#'; damaged
      elseif ch == '?'; unknown
      else error("Unknown symbol") end
    end |> collect
    damaged_sizes = collect(parse(Int, x) for x in eachsplit(sizes_raw, ","))
    push!(rows, Row(springs, damaged_sizes))
  end
  rows
end

struct State
  size_i::Int32
  cur_size::Int32
end

function calc_arrangements(springs::Vector{Cell}, sizes::Vector{Int})
  last_size_i = lastindex(sizes)
  states = Dict{State,Int64}(
    State(i, s - 1) => 0 for i in 1:last_size_i+1, s in eachindex(springs))
  states[State(firstindex(sizes), 0)] = 1
  for i in firstindex(springs):lastindex(springs)+1
    sp = i > lastindex(springs) ? operational : springs[i]
    for (s, count) in collect(states)
      count > 0 || continue
      (; size_i, cur_size) = s
      if sp == damaged
        states[s] -= count
        if size_i <= last_size_i # false: fail, too many dmg groups
          states[State(size_i, cur_size + 1)] += count
        end
      elseif sp == unknown && size_i <= last_size_i && cur_size + 1 <= sizes[size_i]
        # Split as "damaged"
        states[State(size_i, cur_size + 1)] += count
        # The symbol in the current state is treated as "operational"
      end
      if sp != damaged && cur_size > 0
        states[s] -= count
        if sizes[size_i] == cur_size # false: fail, incorrect dmg size
          states[State(size_i + 1, 0)] += count
        end
      end
    end
  end
  states[State(last_size_i + 1, 0)]
end

function part1(rows::Vector{Row})
  result = 0
  for (; springs, damaged_sizes) in rows
    result += calc_arrangements(springs, damaged_sizes)
  end
  result
end

function part2(rows::Vector{Row})
  result = 0
  for (; springs, damaged_sizes) in rows
    new_springs = repeat([springs; [unknown]], 5)[begin:end-1]
    new_damaged_sizes = repeat(damaged_sizes, 5)
    result += calc_arrangements(new_springs, new_damaged_sizes)
  end
  result
end

example = parse_input("""
  ???.### 1,1,3
  .??..??...?##. 1,1,3
  ?#?#?#?#?#?#?#? 1,3,1,6
  ????.#...#... 4,1,1
  ????.######..#####. 1,6,5
  ?###???????? 3,2,1
  """)
println("[Example p1] $(part1(example))") # 21
println("[Example p2] $(part2(example))") # 525152

data = parse_input(Utils.readday(12))
println("[Part 1] $(part1(data))") # 8180
@time println("[Part 2] $(part2(data))") # 620189727003627
